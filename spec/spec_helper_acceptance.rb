require 'beaker-puppet'
require 'beaker-rspec'

# Install Puppet on all hosts
install_puppet_on(hosts)

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    # Install module to all hosts
    hosts.each do |host|
      install_dev_puppet_module_on(
        host,
        source:              module_root,
        module_name:         'recursive_file_permissions',
        target_module_path:  '/etc/puppet/modules',
      )
    end
  end
end
