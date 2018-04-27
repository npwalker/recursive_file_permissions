function recursive_file_permissions::join($data, $separator) {
  $data.reduce |$result,$element| { "${result}${separator}${element}" }
}
