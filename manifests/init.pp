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
define recursive_file_permissions(
  Recursive_file_permissions::Unixpath           $target_dir = $title,
  Optional[Recursive_file_permissions::Filemode] $file_mode  = undef,
  Optional[Recursive_file_permissions::Filemode] $dir_mode   = undef,
  Optional[String[1]]                            $owner      = undef,
  Optional[String[1]]                            $group      = undef,
) {

  if $facts['os']['family'] == 'windows' {
    fail("${module_name} does not support Windows")
  }

  unless $file_mode or $dir_mode or $owner or $group {
    fail('At least one of file_mode, dir_mode, owner, or group is required')
  }

  # Define the find arguments to find and fix any of the permissions we want to
  # recursively manage. Each element defines:
  # 
  #   - input. The param this relates to. If not undef, the check will be used.
  #   - find.  String.  Find args that will identify files in need of fixing.
  #   - fix.   String.  Find -exec command to fix identified files.
  #
  $v = case $facts['os']['family'] {
    'AIX', 'Solaris': { ''    } # Doesn't support -c or -v
    'Darwin':         { '-v'  } # Doesn't support the -c flag, but has -v
    default:          { '-c'  } # Beautifully verbose output
  }

  # -h --no-dereference
  # affect each symbolic link instead of any referenced file
  # (useful only on systems that can change the ownership/group of a symlink)
  $h = case $facts['os']['family'] {
    default: { '-h' }
  }

  $validators = [
    { input  => $file_mode,
      find   => shellquote('(', '-type', 'f', '!', '-perm', $file_mode, ')'),
      fix    => "-exec chmod ${v} ${file_mode} {} \\;",
    },
    { input => $dir_mode,
      find  => shellquote('(', '-type', 'd', '!', '-perm', $dir_mode, ')'),
      fix   => "-exec chmod ${v} ${dir_mode} {} \\;",
    },
    { input => $owner,
      find  => shellquote('(', '!', '-user', $owner, ')'),
      fix   => "-exec chown ${v} ${h} ${shellquote($owner)} {}  \\;",
    },
    { input => $group,
      find  => shellquote('(', '!', '-group', $group, ')'),
      fix   => "-exec chgrp ${v} ${h} ${shellquote($group)} {} \\;",
    },
  ]

  $shellsafe_dir = shellquote($target_dir)

  # Build a set of find arguments that will identify if ANY file is out of
  # sync, on any of the criteria defined by the validators.
  $onlyif_find_args = $validators.reduce([]) |$arr,$validator| {
    $validator[input] ? {
      undef   => $arr,
      default => $arr << $validator[find]
    }
  }.recursive_file_permissions::join(' -o ')

  # This will become the onlyif commmand to run.
  $onlyif  = "find ${shellsafe_dir} ${onlyif_find_args} | grep '.*'"

  # Build an &&-joined command series to run that will find and fix any
  # deviation from the desired state of any validator.
  $command = $validators.reduce([]) |$arr,$validator| {
    $validator[input] ? {
      undef   => $arr,
      default => $arr << "find ${shellsafe_dir} '(' ${validator[find]} ')' ${validator[fix]}"
    }
  }.recursive_file_permissions::join(' && ')

  # The result is a single Exec that finds and fixes all managed permissions,
  # recursively, idempotently.
  exec { "recursive_file_permissions:${target_dir}":
    path      => $facts['path'],
    logoutput => true,
    onlyif    => $onlyif,
    command   => $command,
  }

}
