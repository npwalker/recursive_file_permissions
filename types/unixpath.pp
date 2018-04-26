# Copied from https://github.com/puppetlabs/puppetlabs-stdlib/commit/c95ae34f225b402a91a83bf822832f3d10c21fd4
type Recursive_file_permissions::Unixpath = Pattern[/^\/([^\/\0]+\/*)*$/]
