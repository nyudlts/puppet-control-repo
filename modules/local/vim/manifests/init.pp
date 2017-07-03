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
  String $home = lookup("vim::home"),
  String $plugin = $title,
  String $group = lookup("vim::group"),
  String $user = lookup("vim::user"),
  String $home_dir = "$home/${user}",
  String $test = lookup("vim::test"),
  Array $packages = lookup("vim::packages", Array[String], 'unique'),
) {

  #alert ("The idenity user is: $user")
  #alert ("The home: $home")

  ensure_packages([ $packages ], {'ensure' => 'present'})

  yumrepo { 'mcepl-vim8' :
    name             => 'mcepl-vim8',
    descr            => 'Copr repo for vim8 owned by mcepl',
    baseurl          => 'https://copr-be.cloud.fedoraproject.org/results/mcepl/vim8/epel-7-$basearch/',
    gpgcheck         => 1,
    gpgkey           => 'https://copr-be.cloud.fedoraproject.org/results/mcepl/vim8/pubkey.gpg',
    repo_gpgcheck    => 0,
    enabled          => 1,
  }

  file { "${home}/${user}/README.vim" :
    ensure => file,
    owner  => $user,
    group  =>  $user,
    source => "puppet:///modules/vim/README.vim",
  }

}
