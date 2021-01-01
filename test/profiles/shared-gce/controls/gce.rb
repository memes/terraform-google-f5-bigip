# frozen_string_literal: true

# General BIG-IP VM inspec control - ensures that common parameters match
# expectations based on Terraform input variables and output values.

# The set of keys that may be added by module
MODULE_METADATA_KEYS = %w[serial-port-enable install_cloud_libs
                          admin_password_key as3_payload do_payload ssh-keys user-data shutdown-script
                          startup-script secret_implementor cfe_payload].freeze

# rubocop:disable Metrics/BlockLength
control 'gce_attributes' do
  title 'Verify BIG-IP GCE attributes'

  self_links = input('output_self_links')
  project_id = input('output_project_id')
  zones = input('output_zones')
  service_account = input('output_service_account')
  num_nics = input('input_num_nics').to_i
  num_instances = input('input_num_instances', value: '1').to_i
  tags = input('input_tags', value: '[]').gsub(/(?:[\[\]]|\\?")/, '').gsub(', ', ',').split(',')
  min_cpu_platform = input('input_min_cpu_platform', value: 'Intel Skylake')
  machine_type = input('input_machine_type', value: 'n1-standard-4')
  automatic_restart = input('input_automatic_restart', value: 'true').to_s.downcase == 'true'
  preemptible = input('input_preemptible', value: 'false').to_s.downcase == 'true'
  delete_disk_on_destroy = input('input_delete_disk_on_destroy', value: 'true').to_s.downcase == 'true'
  # TODO: @memes - disabling unused inputs until initialize_params is working
  # rubocop:todo Layout/LineLength
  # image = input('input_image',
  #               value: 'projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-0-0-9-payg-good-25mbps-201110225418')
  # rubocop:enable Layout/LineLength
  # disk_type = input('input_disk_type', value: 'pd-ssd')
  # disk_size_gb = input('input_disk_size_gb', value: '')

  # Do the number of instances match expectations?
  describe 'number of instances' do
    it 'should match expectations' do
      expect(self_links.length).to eq num_instances
    end
  end

  self_links.each_with_index do |url, index|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures

    # Verify attributes that are present in the base subject
    describe params['name'] do
      it 'project ID should match Terraform project_id' do
        expect(params['project']).to cmp project_id
      end

      it 'compute engine attributes' do
        instance = google_compute_instance(project: params['project'], zone: params['zone'], name: params['name'])
        expect(instance).to exist
        expect(instance.status).to cmp 'RUNNING'
        expect(instance.zone).to match %r{/#{zones[index % zones.length]}$}
        expect(instance.machine_type).to match %r{/machineTypes/#{machine_type}$}
        expect(instance.min_cpu_platform).to cmp min_cpu_platform
        expect(instance.scheduling.automatic_restart).to cmp automatic_restart
        expect(instance.scheduling.preemptible).to cmp preemptible
        expect(instance.service_accounts.first.email).to cmp service_account
        expect(instance.service_accounts.first.scopes.length).to eq 1
        expect(instance.service_accounts.first.scopes).to cmp(/cloud-platform/)

        # Test base network configuration - deeper inspection is in separate
        # describe block
        expect(instance.can_ip_forward).to cmp true
        expect(instance.network_interfaces_count).to cmp num_nics
        if tags.nil? || tags.empty?
          expect(instance.tag_count).to eq 0
          expect(instance.tags.items).to be_nil
        else
          expect(instance.tags.items.to_set).to cmp tags.to_set
        end

        # Test disk values
        expect(instance.disks.length).to eq 1
        expect(instance.disks.first.auto_delete).to cmp delete_disk_on_destroy
        expect(instance.disks.first.boot).to cmp true

        # TODO: @memes - are the initialize_params properties broken? Can't
        # get them to return property values through expect or should methods
        # or by changing subject to deeper properties. Object is always empty
        # with no parent.

        # expect(instance.disks.first.initialize_params).not_to be_nil
        # expect(instance.disks.first.initialize_params.disk_type).to cmp disk_type
        # expect(instance.disks.first.initialize_params.source_image).to cmp image
        # if disk_size_gb.empty?
        #   expect(instance.disks.first.initialize_params.disk_size_gb).not_to be_empty
        # else
        #   expect(instance.disks.first.initialize_params.disk_size_gb).to cmp disk_size_gb
        # end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

# rubocop:todo Metrics/BlockLength
control 'gce_labels' do
  title 'Verify BIG-IP GCE attributes'

  labels = input('input_labels', value: '{}').gsub(/(?:[{}]|\\?")/, '').gsub(', ', ',').split(',').map do |p|
    k, v = p.split('=')
    { k => v }
  end.reduce(:merge)
  self_links = input('output_self_links')

  # Is there a CFE label expected? Make sure it is in the expected label set.
  cfe_label_key = input('output_cfe_label_key')
  cfe_label_value = input('input_cfe_label_value')
  unless cfe_label_key.empty? || cfe_label_value.empty?
    if labels.nil?
      labels = {
        cfe_label_key => cfe_label_value
      }
    else
      labels[cfe_label_key.to_s] = cfe_label_value
    end
  end

  self_links.each do |url|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      it 'labels should meet expectations' do
        lookup = google_compute_instance(project: params['project'], zone: params['zone'],
                                         name: params['name']).labels
        if labels.nil? || labels.empty?
          expect(lookup).to be_nil
        else
          expect(lookup).not_to be_nil
          expect(lookup).not_to be_empty
          expect(lookup.length).to eq labels.length
          labels.each do |key, value|
            expect(lookup).to include({ key => value })
          end
        end
      end
    end
  end
end

STANDARD_CLOUD_LIBS = %w[
  https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.23.1/f5-cloud-libs.tar.gz
  https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.7.0/f5-cloud-libs-gce.tar.gz
  https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm
  https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.17.0/f5-declarative-onboarding-1.17.0-3.noarch.rpm
  https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.16.0/f5-telemetry-1.16.0-4.noarch.rpm
  https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.6.1/f5-cloud-failover-1.6.1-1.noarch.rpm
].freeze

control 'gce_metadata' do
  title 'Verify BIG-IP GCE metadata'

  self_links = input('output_self_links')
  admin_password_secret_manager_key = input('output_admin_password_secret_manager_key')
  metadata = input('input_metadata', value: '{}').gsub(/(?:[{}]|\\?")/, '').gsub(', ', ',').split(',').map do |p|
    k, v = p.split('=')
    { k => v }
  end.reduce(:merge)
  ssh_keys = input('input_ssh_keys', value: '')
  enable_serial_console = input('input_enable_serial_console', value: 'false').to_s.downcase == 'true'
  install_cloud_libs = input('input_install_cloud_libs', value: '[]').gsub(/(?:[\[\]]|\\?")/, '').gsub(', ', ',').split(',')
  use_cloud_init = input('input_use_cloud_init', value: 'false').to_s.downcase == 'true'
  secret_implementor = input('input_secret_implementor', value: 'google_secret_manager')

  self_links.each do |url|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      it 'verifying metadata entries match provided values' do
        lookup = google_compute_instance(project: params['project'], zone: params['zone'],
                                         name: params['name']).metadata
        expect(lookup).not_to be_nil
        expect(lookup).not_to be_empty
        # Turn the retrieved metadata to a regular hash
        metadata_h = lookup['items'].map do |item|
          { item['key'] => item['value'] }
        end.reduce(:merge)

        # Test for expected values as the union of provided metadata and values
        # explicitly set in metadata
        ((metadata.nil? || metadata.empty? ? [] : metadata.keys) | MODULE_METADATA_KEYS).each do |key|
          case key
          when 'serial-port-enable'
            expect(metadata_h[key]).to cmp enable_serial_console.to_s
          when 'install_cloud_libs'
            meta_cloud_libs = metadata_h[key].nil? ? [] : metadata_h[key].split(' ')
            if install_cloud_libs.nil? || install_cloud_libs.empty?
              meta_cloud_libs.each do |lib|
                expect(lib).to be_in STANDARD_CLOUD_LIBS
              end
            else
              expect(meta_cloud_libs).to cmp install_cloud_libs
            end
          when 'admin_password_key'
            expect(metadata_h[key]).to cmp admin_password_secret_manager_key
          when 'as3_payload', 'do_payload', 'shutdown-script', 'cfe_payload'
            expect(metadata_h[key]).not_to be_empty
          when 'ssh-keys'
            if ssh_keys.nil? || ssh_keys.empty?
              expect(metadata_h[key]).to be_nil
            else
              expect(metadata_h[key]).to cmp ssh_keys
            end
          when 'user-data'
            if use_cloud_init
              expect(metadata_h[key]).not_to be_empty
            else
              expect(metadata_h[key]).to be_nil
            end
          when 'startup-script'
            if use_cloud_init
              expect(metadata_h[key]).to be_nil
            else
              expect(metadata_h[key]).not_to be_empty
            end
          when 'secret_implementor'
            if secret_implementor.nil? || secret_implementor.empty? || (secret_implementor == 'google_secret_manager')
              expect(metadata_h[key]).to be_nil.or cmp 'google_secret_manager'
            else
              expect(metadata_h[key]).to cmp secret_implementor
            end
          else
            # all other entries should match the user-supplied metadata values
            expect(metadata_h[key]).not_to be_nil
            expect(metadata_h[key]).to cmp metadata[key]
          end
        end
      end

      it 'metadata should not have extra keys' do
        keys = google_compute_instance(project: params['project'], zone: params['zone'],
                                       name: params['name']).metadata_keys
        extra_keys = keys - ((metadata.nil? || metadata.empty? ? [] : metadata.keys) | MODULE_METADATA_KEYS)
        expect(extra_keys).to be_empty
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

# rubocop:disable Metrics/BlockLength
control 'gce_network_interfaces' do
  title 'Verify BIG-IP GCE network interfaces'

  self_links = input('output_self_links')
  private_addresses = input('output_private_addresses')
  public_addresses = input('output_public_addresses')
  alpha_subnet = input('output_alpha_subnet')
  beta_subnet = input('output_beta_subnet')
  gamma_subnet = input('output_gamma_subnet')
  delta_subnet = input('output_delta_subnet')
  epsilon_subnet = input('output_epsilon_subnet')
  zeta_subnet = input('output_zeta_subnet')
  eta_subnet = input('output_eta_subnet')
  theta_subnet = input('output_theta_subnet')
  num_nics = input('input_num_nics').to_i
  reserve_addresses = input('input_reserve_addresses', value: 'false').to_s.downcase == 'true'
  provision_external_public_ip = input('input_provision_external_public_ip', value: 'true').to_s.downcase == 'true'
  external_subnetwork_tier = input('input_external_subnetwork_tier', value: 'PREMIUM')
  provision_management_public_ip = input('input_provision_management_public_ip', value: 'false').to_s.downcase == 'true'
  management_subnetwork_tier = input('input_management_subnetwork_tier', value: 'PREMIUM')
  provision_internal_public_ip = input('input_provision_internal_public_ip', value: 'false').to_s.downcase == 'true'
  internal_subnetwork_tier = input('input_internal_subnetwork_tier', value: 'PREMIUM')

  # Build up the list of expected subnets based on outputs from module
  expected_subnets = [alpha_subnet, beta_subnet, gamma_subnet, delta_subnet, epsilon_subnet, zeta_subnet, eta_subnet,
                      theta_subnet]

  self_links.each_with_index do |url, index|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      # Verify each network interface configuration
      (0...num_nics).each do |nic|
        it "nic#{nic}" do
          config = google_compute_instance(project: params['project'], zone: params['zone'],
                                           name: params['name']).network_interfaces[nic]
          expect(config).not_to be_nil
          expect(config.subnetwork).to cmp expected_subnets[nic]

          case nic
          when 0
            expect_public_ip = provision_external_public_ip
            expect_network_tier = external_subnetwork_tier
          when 1
            expect_public_ip = provision_management_public_ip
            expect_network_tier = management_subnetwork_tier
          else
            expect_public_ip = provision_internal_public_ip
            expect_network_tier = internal_subnetwork_tier
          end
          private_ips = !private_addresses.empty? && private_addresses.length > index ? private_addresses[index] : []
          public_ips = !public_addresses.empty? && public_addresses.length > index ? public_addresses[index] : []
          expected_address = reserve_addresses && private_ips.length > nic ? private_ips[nic] : nil
          expected_public_address = reserve_addresses && public_ips.length > nic ? public_ips[nic] : nil
          if expected_address.nil?
            expect(config.network_ip).not_to be_empty
          else
            expect(config.network_ip).to cmp expected_address
          end
          if expect_public_ip
            expect(config.access_configs).not_to be_nil
            expect(config.access_configs).not_to be_empty
            expect(config.access_configs.length).to eq 1
            expect(config.access_configs.first.network_tier).to cmp expect_network_tier
            if expected_public_address.nil?
              expect(config.access_configs.first.nat_ip).not_to be_empty
            else
              expect(config.access_configs.first.nat_ip).to cmp expected_public_address
            end
          else
            expect(config.access_configs).to be_nil
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
