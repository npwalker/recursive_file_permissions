require 'spec_helper'

describe 'recursive_file_permissions' do
  let(:title) { '/tmp/blah' }
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

      it 'creates the appropriate onlyif command' do
        is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_onlyif(
          "find /tmp/blah \"(\" \"(\" -type f '!' -perm 0644 \")\" -o \"(\" -type d '!' -perm 0744 \")\" -o \"(\" '!' -user test \")\" -o \"(\" '!' -group test \")\" \")\"  | grep '.*'",
        )
      end

      case os
      when %r{aix}, %r{solaris}
        it 'creates the appropriate command (AIX, Solaris)' do
          is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
            "find /tmp/blah \"(\" \"(\" -type f '!' -perm 0644 \")\" \")\"  -exec chmod  0644 {} \\; && find /tmp/blah \"(\" \"(\" -type d '!' -perm 0744 \")\" \")\"  -exec chmod  0744 {} \\; && find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\"  -exec chown -h  test {}  \\; && find /tmp/blah \"(\" \"(\" '!' -group test \")\" \")\"  -exec chgrp -h  test {} \\;",
          )
        end
      when %r{darwin}
        it 'creates the appropriate command (Darwin)' do
          is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
            "find /tmp/blah \"(\" \"(\" -type f '!' -perm 0644 \")\" \")\"  -exec chmod -v 0644 {} \\; && find /tmp/blah \"(\" \"(\" -type d '!' -perm 0744 \")\" \")\"  -exec chmod -v 0744 {} \\; && find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\"  -exec chown -h -v test {}  \\; && find /tmp/blah \"(\" \"(\" '!' -group test \")\" \")\"  -exec chgrp -h -v test {} \\;",
          )
        end
      else
        it 'creates the appropriate command (Default)' do
          is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
            "find /tmp/blah \"(\" \"(\" -type f '!' -perm 0644 \")\" \")\"  -exec chmod -c 0644 {} \\; && find /tmp/blah \"(\" \"(\" -type d '!' -perm 0744 \")\" \")\"  -exec chmod -c 0744 {} \\; && find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\"  -exec chown -h -c test {}  \\; && find /tmp/blah \"(\" \"(\" '!' -group test \")\" \")\"  -exec chgrp -h -c test {} \\;",
          )
        end
      end

      context 'when ignore_path is set' do
        let(:params) do
          {
            'owner'        => 'test',
            'ignore_paths' => ['/tmp/blah/not_this_one'],
          }
        end

        it 'creates the appropriate onlyif command' do
          is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_onlyif(
            "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" | grep '.*'",
          )
        end

        case os
        when %r{aix}, %r{solaris}
          it 'creates the appropriate command (AIX, Solaris)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
              "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" -exec chown -h  test {}  \\;",
            )
          end
        when %r{darwin}
          it 'creates the appropriate command (Darwin)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
              "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" -exec chown -h -v test {}  \\;",
            )
          end
        else
          it 'creates the appropriate command (Default)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
              "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" -exec chown -h -c test {}  \\;",
            )
          end
        end
      end

      context 'when ignore_path is set with multiple paths' do
        let(:params) do
          {
            'owner'        => 'test',
            'ignore_paths' => ['/tmp/blah/not_this_one', '/tmp/blah/not_this_one_either'],
          }
        end

        it 'creates the appropriate onlyif command' do
          is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_onlyif(
            "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" -a \"(\" '!' -path /tmp/blah/not_this_one_either \")\" | grep '.*'",
          )
        end

        case os
        when %r{aix}, %r{solaris}
          it 'creates the appropriate command (AIX, Solaris)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
              "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" -a \"(\" '!' -path /tmp/blah/not_this_one_either \")\" -exec chown -h  test {}  \\;",
            )
          end
        when %r{darwin}
          it 'creates the appropriate command (Darwin)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
              "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" -a \"(\" '!' -path /tmp/blah/not_this_one_either \")\" -exec chown -h -v test {}  \\;",
            )
          end
        else
          it 'creates the appropriate command (Default)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/blah').with_command(
              "find /tmp/blah \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path /tmp/blah/not_this_one \")\" -a \"(\" '!' -path /tmp/blah/not_this_one_either \")\" -exec chown -h -c test {}  \\;",
            )
          end
        end
      end

      context 'when the paths need quoting' do
        let(:title) { '/tmp/bl $ah' }
        let(:params) do
          {
            'owner'        => 'test',
            'ignore_paths' => ['/tmp/bl $ah/not this one', "/tmp/bl \$ah/not this\/one either"],
          }
        end

        it 'creates the appropriate onlyif command' do
          is_expected.to contain_exec('recursive_file_permissions:/tmp/bl $ah').with_onlyif(
            "find '/tmp/bl $ah' \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this one' \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this/one either' \")\" | grep '.*'",
          )
        end

        case os
        when %r{aix}, %r{solaris}
          it 'creates the appropriate command (AIX, Solaris)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/bl $ah').with_command(
              "find '/tmp/bl $ah' \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this one' \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this/one either' \")\" -exec chown -h  test {}  \\;",
            )
          end
        when %r{darwin}
          it 'creates the appropriate command (Darwin)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/bl $ah').with_command(
              "find '/tmp/bl $ah' \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this one' \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this/one either' \")\" -exec chown -h -v test {}  \\;",
            )
          end
        else
          it 'creates the appropriate command (Default)' do
            is_expected.to contain_exec('recursive_file_permissions:/tmp/bl $ah').with_command(
              "find '/tmp/bl $ah' \"(\" \"(\" '!' -user test \")\" \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this one' \")\" -a \"(\" '!' -path '/tmp/bl $ah/not this/one either' \")\" -exec chown -h -c test {}  \\;",
            )
          end
        end
      end
    end
  end
end
