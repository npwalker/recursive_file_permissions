# file_permissions::set_owner_group_permissions
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   file_permissions::recursive_permissions { 'namevar': }
define file_permissions::recursive_permissions (
  String           $target_dir = $title,
  Optional[String] $file_mode  = undef,
  Optional[String] $dir_mode   = undef,
  Optional[String] $owner      = undef,
  Optional[String] $group      = undef,
) {

  if ($file_mode != undef) {
    exec { "file_permissions ${target_dir} files mode":
      command   => "find ${target_dir}/ -type f ! -perm ${file_mode} -exec chmod -c ${file_mode} {} \\;",
      onlyif    => "find ${target_dir}/ -type f ! -perm ${file_mode} | grep '.*'",
      path      => $::path,
      logoutput => true,
      loglevel  => 'info',
    }
  }

  if ($dir_mode != undef) {
    exec { "file_permissions ${target_dir} directories mode":
      command   => "find ${target_dir}/ -type d ! -perm ${dir_mode} -exec chmod -c ${dir_mode} {} \\;",
      onlyif    => "find ${target_dir}/ -type d ! -perm ${dir_mode} | grep '.*'",
      path      => $::path,
      logoutput => true,
      loglevel  => 'info',
    }
  }

  if ($owner != undef and $group != undef) {
    exec { "file_permissions ${target_dir} owner:group":
      command   => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) -exec chown ${owner}:${group} -c {} \\;",
      onlyif    => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) | grep '.*'",
      path      => $::path,
      logoutput => true,
      loglevel  => 'info',
    }
  }

}
