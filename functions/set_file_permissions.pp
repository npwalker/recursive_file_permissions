function file_permissions::set_file_permissions (
  String $target_dir,
  String $file_mode,
){
  exec { "Set perms of ${target_dir} contents to ${file_mode}":
    command   => "find ${target_dir}/ -type f ! -perm ${file_mode} -exec chmod -c ${file_mode} {} \\;",
    onlyif    => "find ${target_dir}/ -type f ! -perm ${file_mode} | grep '.*'",
    path      => $::path,
    logoutput => true,
    loglevel  => 'info',
  }
}
