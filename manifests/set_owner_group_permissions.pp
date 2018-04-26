# file_permissions::set_owner_group_permissions
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   file_permissions::set_owner_group_permissions { 'namevar': }
define file_permissions::set_owner_group_permissions(
  String $file_mode,
  String $dir_mode,
  String $owner,
  String $group,
  String $target_dir = $title,
) {

  file_permissions::set_file_permissions(
    $target_dir,
    $file_mode,
  )

  file_permissions::set_directory_permissions(
    $target_dir,
    $dir_mode,
  )

  file_permissions::set_file_and_directory_owner_and_group(
    $target_dir,
    $owner,
    $group,
  )

}
