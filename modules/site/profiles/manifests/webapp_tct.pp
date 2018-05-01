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
