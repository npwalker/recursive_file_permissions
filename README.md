# Recursive File Permissions

Manage file and directory permissions recursively in a much more performant way than using `recurse => true`.

## Table of Contents

1. [Description](#description)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Development](#development)

## Description

When using Puppet, it's common to want to ensure the permissions, owner, or group of a large amount of files are correct. Usually because some application needs to read or write those files or just to make sure that they are set with secure permissions. A normal way to do that is with a file resource and the `recurse => true` attribute.

However, using a file resource with `recurse => true` is a recipe for disaster. If `/my_dir` contains 1000's of files, that means Puppet will add 1000's of `file` resources to the catalog and report. This causes agent runs and performance issues with storing those catalogs and reports in PuppetDB.

This module provides a defined type that manages permissions, owner, and group for files using the `find`, `chmod`, `chown`, and `chgrp` commands behind the scenes to quickly determine if files need to be updated. This is a much faster operation than what Puppet would natively do, and it results in only one extra resource in the catalog, not (possibly) thousands.

```puppet
# The old way of using recurse => true, like this:
file { '/opt/app':
  ensure  => directory,
  owner   => 'app_x',
  group   => 'app_x',
  mode    => '0640',
  recurse => true,
}

# Becomes much more performant by doing this:
file { '/opt/app':
  ensure => directory,
}
recursive_file_permissions { '/opt/app':
  file_mode => '0640',
  dir_mode  => '0750',
  owner     => 'app_x',
  group     => 'app_x',
}

```

## Requirements

The requirements for this module are:

* A non-Windows operating system for the Puppet agent.
* The system must have `find`, `chmod`, `chown`, and `chgrp` installed and in the system path.

## Usage

Here's an example of setting file modes, directory modes, owner, and group:

```puppet
recursive_file_permissions { '/my_dir':
  file_mode => '0644',
  dir_mode  => '0755',
  owner     => 'me',
  group     => 'us',
}
```

>Note: The mode of files and directories must be specified separately and correctly. This module does not automatically add the execute bit to directory modes, unlike the `file` resource.

You do not need to include all of the attributes but you must include at least one, otherwise, there wouldn't be anything for it to manage.

For example, if you only want to set the owner, do this:

```puppet
recursive_file_permissions { '/my_dir':
  owner => 'me',
}
```

### Ignoring Paths

Normally you can just specify a file within a managed directory as a separate
file resource to adjust its permissions separately, but due to the way
recursive_file_permissions works it's necessary to explicitly ignore paths:

```puppet
recursive_file_permissions { '/my_dir':
  owner         => 'me',
  ignore_paths  => [ '/my_dir/stuff/*' ]
}
```

Note that if you want to ignore a directory and its contents both will need
adding to the list:

```puppet
ignore_paths => [ '/my_dir/this/', '/my_dir/this/*' ]
```

## Development

PRs welcome.

### Testing

```
# To run spec tests
bundle exec rake spec
# To run beaker acceptance tests (requires vagrant)
bundle exec rake beaker
```
