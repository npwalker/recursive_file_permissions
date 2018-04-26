require 'spec_helper'

describe 'file_permissions::set_owner_group_permissions' do
  let(:title) { 'namevar' }
  let(:params) do
    { 'target_dir' => '/tmp',
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
