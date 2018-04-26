require 'spec_helper'

describe 'recursive_file_permissions' do
  let(:title) { '/tmp' }
  let(:params) do
    {
      'file_mode'  => '0644',
      'dir_mode'   => '0744',
      'owner'      => 'test',
      'group'      => 'test',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
