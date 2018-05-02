# == Class: profile::cms_tct
#
# Full description of class profile here.
#
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#


class profiles::webapp_tct(
  $www_dir = '/var/www',
) {

  include housekeeping
  #include housekeeping::packages
  #housekeeping::user{ 'root': }
  #housekeeping::user{ $user: }
  #housekeeping::gemrc{ 'root': }
  #housekeeping::gemrc{ $user: }


  ensure_packages(['rh-ruby22-ruby'], {'ensure' => 'present'})

  class { 'ruby':
    version         => 'rh-ruby22-ruby',
    gems_version    => 'latest',
    rubygems_update =>  true,
  }
  include ruby::dev
  class { 'ruby::gemrc' :
    gem_command => {
      'gem'     => [ 'no-document' ],
    }
  }

  file { 'rh-ruby22.sh' :
    ensure  => file,
    path    => '/etc/profile.d/rh-ruby22.sh',
    content => template('profiles/rh-ruby22.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
  ensure_packages(['psych'], {'ensure' => '2.2.4', 'provider' => 'gem'})

  include dltsyumrepo::el7::test

  group {'dlib' :
    ensure => present,
    gid    => '200',
  }

  include tct
  include nginx
  nginx::resource::server { "tct.home.wfc" :
    www_root =>  '/var/www/html',
  }

  firewall { '100 allow nginx access on 80' :
    dport  => [80, 443],
    proto  => tcp,
    action => accept,
  }

}
