# frozen_string_literal: true

control 'suite' do
  title 'ha-8nic-full'

  prefix = input('prefix')
  self_links = input('self_links')
  domain_name = input('input_domain_name')

  self_links.each do |url|
    params = url.match(%r{/projects/(?<project>[^/]+)/zones/(?<zone>[^/]+)/instances/(?<name>.+)$}).named_captures
    describe params['name'] do
      it 'should meet naming expectations' do
        instance = google_compute_instance(project: params['project'], zone: params['zone'], name: params['name'])
        expect(instance).to exist
        expect(instance.name).to match(/#{prefix}-ha-8nic-full-[12]$/)
        expect(instance.hostname).to match(/#{prefix}-ha-8nic-full-[12]\.#{domain_name}/)
      end
    end
  end
end

# Include the shared BIG-IP controls
include_controls 'shared-gce'
include_controls 'shared-local'
