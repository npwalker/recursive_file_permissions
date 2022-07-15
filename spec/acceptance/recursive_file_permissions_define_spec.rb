require 'spec_helper_acceptance'

modulepath = '/etc/puppet/modules'

def setup_test_dir(dir)
  on(hosts, "rm -rf '#{dir}'")

  on(hosts, "mkdir -p '#{dir}'")
  on(hosts, "mkdir -p '#{dir}/dirmd'")
  on(hosts, "mkdir -p '#{dir}/ignore'")
  on(hosts, "touch '#{dir}/filemd'")
  on(hosts, "touch '#{dir}/own'")
  on(hosts, "touch '#{dir}/grp'")
  on(hosts, "touch '#{dir}/ignore/filemd'")
  on(hosts, "touch '#{dir}/ignore/own'")
  on(hosts, "touch '#{dir}/ignore/grp'")
end

def stat_owner(path)
  on(hosts, "stat '#{path}' --format '%U'")[0].output.strip
end

def stat_group(path)
  on(hosts, "stat '#{path}' --format '%G'")[0].output.strip
end

def stat_mode(path)
  on(hosts, "stat '#{path}' --format '%a'")[0].output.strip
end

# Exit 0 here allows us to rerun tests without destroying the boxes
on(hosts, 'useradd bob || exit 0')
on(hosts, 'useradd test ||  exit 0')

shared_context 'common' do
  before(:each) do
    setup_test_dir(dir)
    on(hosts, "chown bob:test '#{dir}/own' '#{dir}/ignore/own'")
    on(hosts, "chown test:bob '#{dir}/grp' '#{dir}/ignore/grp'")
    on(hosts, "chmod -R 777 '#{dir}'")
  end
end

describe 'recursive_file_permissions' do
  context 'with basic parameters' do
    let(:dir) { '/tmp/blah' }

    include_context 'common'

    manifest = <<-EOS
      recursive_file_permissions { '/tmp/blah':
        file_mode => '0644',
        dir_mode  => '0744',
        owner     => 'test',
        group     => 'test',
      }
    EOS

    it 'is idempotent with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      apply_manifest(manifest, { catch_changes: true, modulepath: modulepath })
    end

    it 'changes the owner' do
      expect(stat_owner("#{dir}/own")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_owner("#{dir}/own")).to eq 'test'
    end

    it 'changes the group' do
      expect(stat_group("#{dir}/grp")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_group("#{dir}/grp")).to eq 'test'
    end

    it 'changes the dir mode' do
      expect(stat_mode("#{dir}/dirmd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/dirmd")).to eq '744'
    end

    it 'changes the file mode' do
      expect(stat_mode("#{dir}/filemd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/filemd")).to eq '644'
    end
  end

  context 'with ignored_paths' do
    let(:dir) { '/tmp/blah' }

    include_context 'common'

    manifest = <<-EOS
      recursive_file_permissions { '/tmp/blah':
        file_mode => '0644',
        dir_mode  => '0744',
        owner     => 'test',
        group     => 'test',
        ignore_paths => ['/tmp/blah/ignore*']
      }
    EOS

    it 'is idempotent with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      apply_manifest(manifest, { catch_changes: true, modulepath: modulepath })
    end

    it 'changes the owner' do
      expect(stat_owner("#{dir}/own")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_owner("#{dir}/own")).to eq 'test'
    end

    it 'changes the group' do
      expect(stat_group("#{dir}/grp")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_group("#{dir}/grp")).to eq 'test'
    end

    it 'changes the dir mode' do
      expect(stat_mode("#{dir}/dirmd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/dirmd")).to eq '744'
    end

    it 'changes the file mode' do
      expect(stat_mode("#{dir}/filemd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/filemd")).to eq '644'
    end

    it 'doesn\'t change the owner of an ignored path' do
      expect(stat_owner("#{dir}/ignore/own")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_owner("#{dir}/ignore/own")).to eq 'bob'
    end

    it 'doesn\'t change the group of an ignored path' do
      expect(stat_group("#{dir}/ignore/grp")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_group("#{dir}/ignore/grp")).to eq 'bob'
    end

    it 'doesn\'t change the dir mode of an ignored path' do
      expect(stat_mode("#{dir}/ignore")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/ignore")).to eq '777'
    end

    it 'doesn\'t change the file mode of an ignored path' do
      expect(stat_mode("#{dir}/ignore/filemd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/ignore/filemd")).to eq '777'
    end
  end

  context 'with only ignored_paths changed' do
    let(:dir) { '/tmp/blah' }

    before(:each) do
      setup_test_dir(dir)
      # Ensure other paths are set correctly
      on(hosts, "chmod -R 644 #{dir}")
      on(hosts, "chmod 744 #{dir} #{dir}/dirmd")
      on(hosts, "chown -R test:test #{dir}")

      # Only 'change' ignored paths
      on(hosts, "chown bob:test #{dir}/ignore/own")
      on(hosts, "chown test:bob #{dir}/ignore/grp")
      on(hosts, "chmod -R 777 #{dir}/ignore")
    end

    manifest = <<-EOS
      recursive_file_permissions { '/tmp/blah':
        file_mode    => '0644',
        dir_mode     => '0744',
        owner        => 'test',
        group        => 'test',
        ignore_paths => ['/tmp/blah/ignore/*', '/tmp/blah/ignore']
      }
    EOS

    it 'is idempotent with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      apply_manifest(manifest, { catch_changes: true, modulepath: modulepath })
    end

    it 'does not change anything' do
      expect(stat_owner("#{dir}/ignore/own")).to eq 'bob'
      expect(stat_group("#{dir}/ignore/grp")).to eq 'bob'
      expect(stat_mode("#{dir}/ignore")).to eq '777'
      expect(stat_mode("#{dir}/ignore/filemd")).to eq '777'

      apply_manifest(manifest, { catch_changes: true, modulepath: modulepath })

      expect(stat_owner("#{dir}/ignore/own")).to eq 'bob'
      expect(stat_group("#{dir}/ignore/grp")).to eq 'bob'
      expect(stat_mode("#{dir}/ignore")).to eq '777'
      expect(stat_mode("#{dir}/ignore/filemd")).to eq '777'
    end
  end

  context 'with paths that need quoting' do
    let(:dir) { '/tmp/bl $ah' }

    include_context 'common'

    manifest = <<-EOS
      recursive_file_permissions { '/tmp/bl $ah':
        file_mode    => '0644',
        dir_mode     => '0744',
        owner        => 'test',
        group        => 'test',
        ignore_paths => ['/tmp/bl $ah/ignore/*', '/tmp/bl $ah/ignore']
      }
    EOS

    it 'is idempotent with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      apply_manifest(manifest, { catch_changes: true, modulepath: modulepath })
    end

    it 'changes the owner' do
      expect(stat_owner("#{dir}/own")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_owner("#{dir}/own")).to eq 'test'
    end

    it 'changes the group' do
      expect(stat_group("#{dir}/grp")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_group("#{dir}/grp")).to eq 'test'
    end

    it 'changes the dir mode' do
      expect(stat_mode("#{dir}/dirmd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/dirmd")).to eq '744'
    end

    it 'changes the file mode' do
      expect(stat_mode("#{dir}/filemd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/filemd")).to eq '644'
    end

    it 'doesn\'t change the owner of an ignored path' do
      expect(stat_owner("#{dir}/ignore/own")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_owner("#{dir}/ignore/own")).to eq 'bob'
    end

    it 'doesn\'t change the group of an ignored path' do
      expect(stat_group("#{dir}/ignore/grp")).to eq 'bob'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_group("#{dir}/ignore/grp")).to eq 'bob'
    end

    it 'doesn\'t change the dir mode of an ignored path' do
      expect(stat_mode("#{dir}/ignore")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/ignore")).to eq '777'
    end

    it 'doesn\'t change the file mode of an ignored path' do
      expect(stat_mode("#{dir}/ignore/filemd")).to eq '777'
      apply_manifest(manifest, { catch_failures: true, modulepath: modulepath })
      expect(stat_mode("#{dir}/ignore/filemd")).to eq '777'
    end
  end
end
