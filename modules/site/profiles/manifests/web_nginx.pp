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

  include nginx

  #file { '/etc/nginx/nginx.conf' :
  #  ensure  => file,
  #  content => template('profiles/nginx.conf.erb')
  #}

  firewall { '100 allow apache access on 80' :
    #dport  => [80, 443, 5601, 8000, 8001, 8080],
    dport  => [80],
    proto  => tcp,
    action => accept,
  }

}
