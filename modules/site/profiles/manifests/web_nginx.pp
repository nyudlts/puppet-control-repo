# == Class: profile::apache_profile
#
# Full description of class profile here.
#
# === Authors
#
# Flannon flannon@nyu.edu
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class profiles::web_nginx {

  firewall { '100 allow apache access on 80' :
    dport  => [80, 443, 8000, 8080],
    proto  => tcp,
    action => accept,
  }

}
