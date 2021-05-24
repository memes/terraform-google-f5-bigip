# frozen_string_literal: true

# Validates that ConfigSync appropriate firewall rules are present on data-plane
# and control-plane networks.

# rubocop:todo Metrics/BlockLength
control 'fw_dataplane' do
  title 'Verify BIG-IP ConfigSync firewall rule on data-plane network'

  self_link = input('output_dataplane_fw_self_link')
  alpha_net = input('output_alpha_net')
  gamma_net = input('output_gamma_net')
  service_account = input('output_service_account')
  num_nics = input('input_num_nics').to_i

  only_if('data-plane firewall not in fixture') do
    !self_link.empty?
  end

  params = self_link.match(%r{/projects/(?<project>[^/]+)/global/firewalls/(?<name>.+)$}).named_captures
  describe 'data-plane ConfigSync firewall' do
    fw = {}
    it 'exists' do
      fw = google_compute_firewall(project: params['project'], name: params['name'])
      expect(fw).not_to be_nil
    end

    it 'is on the correct VPC network' do
      expect(fw.network).to cmp num_nics > 2 ? gamma_net : alpha_net
    end

    it 'allows ingress between BIG-IP service accounts' do
      expect(fw.source_service_accounts).not_to be_empty
      expect(fw.source_service_accounts).to cmp [service_account]
      expect(fw.target_service_accounts).not_to be_empty
      expect(fw.target_service_accounts).to cmp [service_account]
    end

    it 'is INGRESS' do
      expect(fw.direction).to cmp 'INGRESS'
    end

    it 'has correct protocols and ports' do
      expect(fw.denied).to be_nil
      expect(fw.allowed).not_to be_empty
      allowed = fw.allowed.map do |entry|
        { entry.ip_protocol => entry.ports }
      end.reduce(:merge)
      expect(allowed.keys).to cmp %w[tcp udp]
      expect(allowed).to include(
        'tcp' => %w[
          443
          4353
          6123-6128
        ],
        'udp' => [
          '1026'
        ]
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength

# rubocop:todo Metrics/BlockLength
control 'fw_controlplane' do
  title 'Verify BIG-IP ConfigSync firewall rule on control-plane network'

  self_link = input('output_management_fw_self_link')
  beta_net = input('output_beta_net')
  service_account = input('output_service_account')

  only_if('control-plane firewall not in fixture') do
    !self_link.empty?
  end

  params = self_link.match(%r{/projects/(?<project>[^/]+)/global/firewalls/(?<name>.+)$}).named_captures
  describe 'data-plane ConfigSync firewall' do
    fw = {}
    it 'exists' do
      fw = google_compute_firewall(project: params['project'], name: params['name'])
      expect(fw).not_to be_nil
    end

    it 'is on the correct VPC network' do
      expect(fw.network).to cmp beta_net
    end

    it 'allows ingress between BIG-IP service accounts' do
      expect(fw.source_service_accounts).not_to be_empty
      expect(fw.source_service_accounts).to cmp [service_account]
      expect(fw.target_service_accounts).not_to be_empty
      expect(fw.target_service_accounts).to cmp [service_account]
    end

    it 'is INGRESS' do
      expect(fw.direction).to cmp 'INGRESS'
    end

    it 'has correct protocols and ports' do
      expect(fw.denied).to be_nil
      expect(fw.allowed).not_to be_empty
      allowed = fw.allowed.map do |entry|
        { entry.ip_protocol => entry.ports }
      end.reduce(:merge)
      expect(allowed.keys).to cmp ['tcp']
      expect(allowed).to include(
        'tcp' => [
          '443'
        ]
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
