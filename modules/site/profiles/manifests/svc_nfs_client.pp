# == Class: profiles::svc_nfsclnt
#
# Full description of class profile here.
#
#
# === Authors
#
# Flannon Jackson <flannon@nyu.edu>
#
# === Copyright
#
# Copyright 2016 Your NYULibraries, unless otherwise noted.
#
class profiles::svc_nfs_client {


  # Add default group and users
  group { 'dlib' :
    ensure => present,
    gid    => '200',
  }


}
