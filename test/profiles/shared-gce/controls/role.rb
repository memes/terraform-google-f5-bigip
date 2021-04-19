# frozen_string_literal: true

# Validates that CFE custom role is present.

EXPECTED_PERMISSIONS = [
  'compute.forwardingRules.get',
  'compute.forwardingRules.list',
  'compute.forwardingRules.setTarget',
  'compute.instances.create',
  'compute.instances.get',
  'compute.instances.list',
  'compute.instances.updateNetworkInterface',
  'compute.networks.updatePolicy',
  'compute.routes.create',
  'compute.routes.delete',
  'compute.routes.get',
  'compute.routes.list',
  'compute.targetInstances.get',
  'compute.targetInstances.list',
  'compute.targetInstances.use',
  'storage.buckets.create',
  'storage.buckets.delete',
  'storage.buckets.get',
  'storage.buckets.list',
  'storage.buckets.update',
  'storage.objects.create',
  'storage.objects.delete',
  'storage.objects.get',
  'storage.objects.list',
  'storage.objects.update'
].freeze

control 'cfe_custom_role' do
  title 'Verify BIG-IP CFE custom role'

  role_id = input('output_role_id')

  only_if('fixture includes CFE custom role') do
    !role_id.empty?
  end

  params = role_id.match(%r{^projects/(?<project>[^/]+)/roles/(?<name>.+)$}).named_captures
  describe params['name'] do
    role = {}
    it 'exists' do
      role = google_project_iam_custom_role(project: params['project'], name: params['name'])
      expect(role).not_to be_nil
    end

    it 'has the correct permissions' do
      expect(role.included_permissions).to cmp EXPECTED_PERMISSIONS
    end
  end
end
