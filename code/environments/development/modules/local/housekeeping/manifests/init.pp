#
class housekeeping (
    $user = $housekeeping::params::user
) inherits housekeeping::params {

  ensure_packages([
    'bzip2-devel',
    'bind-utils',
    'epel-release',
    'gdbm-devel',
    'gcc',
    'gcc-c++',
    'git',
    'libffi-devel',
    'libxslt-devel',
    'libyaml-devel',
    'lsof',
    'nfs-utils',
    'ncurses-devel',
    'make',
    'openssl-devel',
    'patch',
    'readline-devel',
    'sqlite-devel',
    'zlib-devel',
    'unzip',
    'zip',
    'zlib-devel',
  ])

  #file { '/home/root':
  #  ensure => link,
  #  target => '/root',
  #}

  housekeeping::user{ 'root': }
  housekeeping::user{ 'centos': }

  housekeeping::gemrc{ 'root': }
  housekeeping::gemrc{ 'centos': }

}
