# frozen_string_literal: true

control 'suite' do
  title 'c7min'

  prefix = input('output_prefix')
  self_links = input('output_self_links')
  zones = input('output_zones')
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

  self_links.each_with_index do |url, index|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      it 'should meet naming expectations' do
        instance = google_compute_instance(project: params['project'], zone: params['zone'], name: params['name'])
        expect(instance).to exist
        expect(instance.name).to match(/#{prefix}-c7min-[01]$/)
        # rubocop:disable Layout/LineLength
        expect(instance.hostname).to match(/#{prefix}-c7min-[01]\.#{zones[index % zones.length]}\.c\.#{params["project"]}\.internal/)
        # rubocop:enable Layout/LineLength
      end
    end
  end
end

# Include the shared BIG-IP controls
include_controls 'shared-gce'
include_controls 'shared-local'
