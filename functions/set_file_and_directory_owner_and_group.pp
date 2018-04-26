function file_permissions::set_file_and_directory_owner_and_group (
  String $target_dir,
  String $owner,
  String $group,
){
  exec { "Set user/group of ${target_dir} contents to ${owner}:${group}":
    command   => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) -exec chown ${owner}:${group} -c {} \\;",
    onlyif    => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) | grep '.*'",
    path      => $::path,
    logoutput => true,
    loglevel  => 'info',
  }
}
