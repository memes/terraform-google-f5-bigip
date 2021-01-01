# frozen_string_literal: true

control 'suite' do
  title 'ha-2nic-minimal'

  prefix = input('output_prefix')
  self_links = input('output_self_links')
  zones = input('output_zones')

  self_links.each_with_index do |url, index|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      it 'should meet naming expectations' do
        instance = google_compute_instance(project: params['project'], zone: params['zone'], name: params['name'])
        expect(instance).to exist
        expect(instance.name).to match(/#{prefix}-ha-2nic-minimal-[01]$/)
        # rubocop:disable Layout/LineLength
        expect(instance.hostname).to match(/#{prefix}-ha-2nic-minimal-[01]\.#{zones[index % zones.length]}\.c\.#{params["project"]}\.internal/)
        # rubocop:enable Layout/LineLength
      end
    end
  end
end

# Include the shared BIG-IP controls
include_controls 'shared-gce'
include_controls 'shared-local'
