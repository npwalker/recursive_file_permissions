# recursive_file_permissions
#
# A defined type for changing file and directory permissions recursively.
#
# @summary Manage file permissions recursively.
#
# @example
#   recursive_file_permissions { '/my_dir':
#     file_mode => '0644',
#     dir_mode  => '0744',
#     owner     => 'me',
#     group     => 'us',
#    }
#
define recursive_file_permissions (
  Recursive_file_permissions::Unixpath           $target_dir  = $title,
  Optional[Recursive_file_permissions::Filemode] $file_mode   = undef,
  Optional[Recursive_file_permissions::Filemode] $dir_mode    = undef,
  Optional[String[1]]                            $owner       = undef,
  Optional[String[1]]                            $group       = undef,
) {

  if $facts['os']['family'] == 'windows' {
    fail("${module_name} does not support Windows")
  }

  unless $file_mode or $dir_mode or $owner or $group {
    fail('At least one of file_mode, dir_mode, owner, or group is required')
  }

  Exec {
    path      => $facts['path'],
    logoutput => true,
    loglevel  => 'info',
  }

  if $dir_mode {
    exec { "Set perms of ${target_dir} directories to ${dir_mode}":
      command => "find ${target_dir}/ -type d ! -perm ${dir_mode} -exec chmod -c ${dir_mode} {} \\;",
      onlyif  => "find ${target_dir}/ -type d ! -perm ${dir_mode} | grep '.*'",
    }
  }
  if $file_mode {
    exec { "Set perms of ${target_dir} contents to ${file_mode}":
      command => "find ${target_dir}/ -type f ! -perm ${file_mode} -exec chmod -c ${file_mode} {} \\;",
      onlyif  => "find ${target_dir}/ -type f ! -perm ${file_mode} | grep '.*'",
    }
  }
  if $owner and $group {
    exec { "Set owner and group of ${target_dir} contents to ${owner}:${group}":
      command => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) -exec chown ${owner}:${group} -c {} \\;",
      onlyif  => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) | grep '.*'",
    }
  } elsif $owner {
    exec { "Set owner of ${target_dir} contents to ${owner}":
      command => "find ${target_dir}/ \\( ! -user ${owner} \\) -exec chown ${owner} -c {} \\;",
      onlyif  => "find ${target_dir}/ \\( ! -user ${owner} \\) | grep '.*'",
    }
  } elsif $group {
    exec { "Set group of ${target_dir} contents to ${group}":
      command => "find ${target_dir}/ \\( ! -group ${group} \\) -exec chgrp ${group} -c {} \\;",
      onlyif  => "find ${target_dir}/ \\( ! -group ${group} \\) | grep '.*'",
    }
  }
}
