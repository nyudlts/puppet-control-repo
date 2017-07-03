# Class: vim
# ===========================
#
# Full description of class vim here.
#
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class vim(
  String $home = lookup('vim::home'),
  String $plugin = $title,
  String $group = lookup('vim::group'),
  String $user = lookup('vim::user'),
  String $home_dir = "$home/${user}"
) {
  alert ("The idenity user is: $user")
  alert ("The home: $home")

  yumrepo { 'mcepl-vim8' :
    name             => 'mcepl-vim8',
    descr            => 'Copr repo for vim8 owned by mcepl',
    baseurl          => 'https://copr-be.cloud.fedoraproject.org/results/mcepl/vim8/epel-7-$basearch/',
    gpgcheck         => 1,
    gpgkey           => 'https://copr-be.cloud.fedoraproject.org/results/mcepl/vim8/pubkey.gpg',
    repo_gpgcheck    => 0,
    enabled          => 1,
  }

  ensure_packages([
  'automake',
  'centos-release-scl',
  'devtoolset-4-gcc',
  'devtoolset-4-gcc-c++',
  'gcc',
  'gcc-c++',
  'kernel-devel',
  'cmake',
  'python34-devel',
  'vim-enhanced',
  'vim-minimal',
  ], {'ensure' => 'present'})

  
  file_line { 'scl_enable_devtoolset-4' :
    ensure => absent,
    path   => "${home}/${user}/README",
    line   => 'scl enable devtoolset-4 bash',
  }

}
