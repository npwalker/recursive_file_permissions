#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with file_permissions](#setup)
    * [What file_permissions affects](#what-file_permissions-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with file_permissions](#beginning-with-file_permissions)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

You often want to ensure the permissions, owner, or group of a large amount of files are correct so your application is able to read/write those files or just to make sure that they are set with secure permissions.

However, using a file resource with `recurse => true` is a recipe for slow agent runs and performance issues storing catalogs and reports in PuppetDB.

This module provides a defined type that allows you to manage permissions, owner, and group for files using the `find` command behind the scenes to quickly determine if files need to be updated and then doing so if need be in a fraction of the time it would take a recursive file resource in Puppet to do the same thing.

## Setup

### Setup Requirements

The only requirement of the module is that the target system has `find` installed and the flags that are used are present.

## Usage

Here's an example invocation of the recursive_file_permissions defined type.

```
recursive_file_permissions { '/my_dir':
  file_mode => '0644',
  dir_mode  => '0744',
  owner     => 'me',
  group     => 'us',
}
```

You do not need to include all of the attributes but you must include at least one, otherwise, there wouldn't be anything for it to manage.

## Development

PRs welcome.
