require 'spec_helper_acceptance'

modulepath = '/etc/puppet/modules'

describe 'recursive_file_permissions' do
  context 'with basic params' do
    manifest = <<-EOS
      recursive_file_permissions { '/tmp/blah':
        file_mode => '0644',
        dir_mode  => '0744',
        owner     => 'test',
        group     => 'test',
      }
    EOS

    before(:all) do
      on(hosts, 'mkdir -p /tmp/blah')
      on(hosts, 'mkdir -p /tmp/blah/dirmd')
      on(hosts, 'touch /tmp/blah/filemd')
      on(hosts, 'touch /tmp/blah/own')
      on(hosts, 'touch /tmp/blah/grp')
      # Exit 0 here allows us to rerun tests without destroying the boxes
      on(hosts, 'useradd bob || exit 0')
      on(hosts, 'useradd test ||  exit 0')
    end

    before(:each) do
      on(hosts, 'chown bob:test /tmp/blah/own')
      on(hosts, 'chown test:bob /tmp/blah/grp')
      on(hosts, 'chmod -R 777 /tmp/blah')
    end

    it 'is idempotent with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      apply_manifest(manifest, { catch_changes: true, modulepath: modulepath })
    end

    it 'changes the owner' do
      expect(on(hosts, "stat /tmp/blah/own --format '%U'")[0].output).to eq "bob\n"
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(on(hosts, "stat /tmp/blah/own --format '%U'")[0].output).to eq "test\n"
    end

    it 'changes the group' do
      expect(on(hosts, "stat /tmp/blah/grp --format '%G'")[0].output).to eq "bob\n"
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(on(hosts, "stat /tmp/blah/grp --format '%G'")[0].output).to eq "test\n"
    end

    it 'changes the dir mode' do
      expect(on(hosts, "stat /tmp/blah/dirmd --format '%a'")[0].output).to eq "777\n"
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(on(hosts, "stat /tmp/blah/dirmd --format '%a'")[0].output).to eq "744\n"
    end

    it 'changes the file mode' do
      expect(on(hosts, "stat /tmp/blah/filemd --format '%a'")[0].output).to eq "777\n"
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(on(hosts, "stat /tmp/blah/filemd --format '%a'")[0].output).to eq "644\n"
    end
  end
end
