# frozen_string_literal: true

control 'suite' do
  title 'cfe-8nic-full'

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
end
# Include the shared BIG-IP controls
include_controls 'shared-gce'
include_controls 'shared-local'
