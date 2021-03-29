# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
control 'suite' do
  title 'cfe-8nic-full'

  prefix = input('output_prefix')
  bigip_version = input('output_bigip_version')
  self_links = input('output_self_links')
  domain_name = input('input_domain_name')
  cfe_label_key = input('input_cfe_label_key', value: 'f5_cloud_failover_label')
  cfe_label_value = input('input_cfe_label_value')

  # Actual label comparison will be performed in shared gce control; this just
  # ensures the inputs are not empty given that the CFE module fixtures should
  # all include them.
  describe 'CFE label inputs' do
    it 'key' do
      expect(cfe_label_key).not_to be_empty
    end
    it 'value' do
      expect(cfe_label_value).not_to be_empty
    end
  end

  self_links.each do |url|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      it 'should meet naming expectations' do
        instance = google_compute_instance(project: params['project'], zone: params['zone'], name: params['name'])
        expect(instance).to exist
        expect(instance.name).to match(/#{prefix}-#{bigip_version}-#{bigip_version}-c8full-[12]$/)
        expect(instance.hostname).to match(/#{prefix}-#{bigip_version}-#{bigip_version}-c8full-[12]\.#{domain_name}/)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

# Include the shared BIG-IP controls
include_controls 'shared-gce'
include_controls 'shared-local'
