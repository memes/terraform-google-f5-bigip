# frozen_string_literal: true

require 'time'
require 'inspec'

# rubocop:todo Metrics/BlockLength
control 'serial_log' do
  title 'Verify BIG-IP onboarding serial output'

  self_links = input('output_self_links')
  num_nics = input('input_num_nics').to_i
  use_cloud_init = input('input_use_cloud_init', value: 'false').to_s.downcase == 'true'
  custom_script = input('input_custom_script', value: '')

  only_if('User requested skipping of control') do
    ENV['KITCHEN_SKIP_ONBOARD_DELAY'].nil?
  end

  # For VMs with >1 nics, give extra time for the onboarding process to complete
  onboarding_delay = num_nics < 2 ? 300 : 600

  self_links.map do |url|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      # rubocop:todo Layout/LineLength
      cmd = command(+"gcloud compute instances describe #{params['name']} --zone #{params['zone']} --project #{params['project']} --format 'value(creationTimestamp)'")
      # rubocop:enable Layout/LineLength
      it 'gcloud describe creation timestamp succeeded' do
        expect(cmd).not_to be_nil
        expect(cmd.exit_status).to eq 0
        expect(cmd.stdout).not_to be_empty
      end
      # rubocop:todo Layout/LineLength
      Inspec::Log.info(+"#{params['name']} - Control may appear to stop while waiting for onboarding to complete; onboarding delay is #{onboarding_delay}")
      # rubocop:enable Layout/LineLength
      creation_timestamp = Time.iso8601(cmd.stdout)
      it 'instance creation timestamp is valid' do
        expect(creation_timestamp).not_to be_nil
        expect(creation_timestamp).to be < Time.now
      end
      delay_secs = (creation_timestamp + onboarding_delay - Time.now).ceil
      if delay_secs.positive?
        Inspec::Log.info(+"#{params['name']} - Onboarding delay not met; sleeping for another #{delay_secs}s")
        sleep(delay_secs)
      end

      # rubocop:todo Layout/LineLength
      cmd = command(+"gcloud compute instances get-serial-port-output #{params['name']} --zone #{params['zone']} --project #{params['project']}")
      # rubocop:enable Layout/LineLength
      it 'gcloud serial output exists' do
        expect(cmd).not_to be_nil
        expect(cmd.exit_status).to eq 0
      end
      onboarding_output = cmd.stdout.split(/\r?\n/).select { |o| %r{/config/cloud/gce/[^.]+\.sh}.match(o) }

      it 'onboarding scripts are present' do
        expect(onboarding_output).not_to be_empty
      end

      it 'main onboarding script has started' do
        expect(onboarding_output.any? { |o| o['initialSetup.sh: Info: Initialisation starting'] }).to be true
      end

      it 'earlySetup.sh ran successfully' do
        expect(onboarding_output.any? { |o| o['earlySetup.sh'] }).to be true
        expect(onboarding_output.any? { |o| o['earlySetup.sh: Error:'] }).to be false
      end

      it 'multiNicMgmtSwap.sh ran successfully' do
        if num_nics == 1
          expect(onboarding_output.any? { |o| o['multiNicMgmtSwap.sh: Nothing to do'] }).to be true
        else
          expect(onboarding_output.any? { |o| o['multiNicMgmtSwap.sh: Rebooting'] }).to be true
        end
      end

      it 'initialNetworking.sh ran successfully' do
        expect(onboarding_output.any? do |o|
                 o['initialNetworking.sh: Info: Initial networking configuration is complete']
               end).to be true
      end

      it 'admin password was set successfully' do
        expect(onboarding_output.any? { |o| o['initialSetup.sh: Info: Admin password has been changed'] }).to be true
      end

      it 'installCloudLibs.sh ran successfully' do
        expect(onboarding_output.any? { |o| o['installCloudLibs.sh: Info: Admin password is unknown'] }).to be false
        expect(onboarding_output.any? { |o| o['installCloudLibs.sh: Info: Cloud libraries are installed'] }).to be true
      end

      it 'declarativeOnboarding.sh ran successfully' do
        expect(onboarding_output.any? do |o|
                 o['declarativeOnboarding.sh: Info: Declarative Onboarding is complete']
               end).to be true
      end

      it 'applicationServices3.sh ran successfully' do
        expect(onboarding_output.any? { |o| o['applicationServices3.sh: Info: AS3 payload is installed'] }).to be true
      end

      # Can only reliably test custom script execution with the default no-op script since content is known;
      # skip if a user provided script is present.
      if custom_script.empty?
        it 'customConfig.sh ran successfully' do
          expect(onboarding_output.any? { |o| o['customConfig.sh'] }).to be true
          expect(onboarding_output.any? { |o| o['customConfig.sh: Error:'] }).to be false
        end
      end

      it 'initialSetup.sh ran successfully' do
        expect(onboarding_output.any? { |o| o['initialSetup.sh: Info: Initialisation complete'] }).to be true
      end

      if use_cloud_init
        # Success is disabling of intitial setup unit and enabling of reset management route unit
        it 'systemd units updated successfully' do
          expect(onboarding_output.any? do |o|
                   o['initialSetup.sh: Info: Actions complete: disabling f5-gce-initial-setup.service unit']
                 end).to be true
          expect(onboarding_output.any? do |o|
                   # rubocop:todo Layout/LineLength
                   o['initialSetup.sh: Info: Actions complete: enabling f5-gce-management-route.service for future boot']
                   # rubocop:enable Layout/LineLength
                 end).to be true
        end
      else
        # Check that resetManagementRoute.sh was executed
        it 'resetManagementRoute.sh ran successfully' do
          expect(onboarding_output.any? { |o| o['resetManagementRoute.sh: complete'] }).to be true
        end
      end

      it 'onboarding output does not contain errors' do
        expect(onboarding_output.any? { |o| o['Error:'] }).to be false
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
