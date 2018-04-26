function file_permissions::set_directory_permissions (
  String $target_dir,
  String $dir_mode,
){
  exec { "Set perms of ${target_dir} directories to ${dir_mode}":
    command   => "find ${target_dir}/ -type d ! -perm ${dir_mode} -exec chmod -c ${dir_mode} {} \\;",
    onlyif    => "find ${target_dir}/ -type d ! -perm ${dir_mode} | grep '.*'",
    path      => $::path,
    logoutput => true,
    loglevel  => 'info',
  }
}
