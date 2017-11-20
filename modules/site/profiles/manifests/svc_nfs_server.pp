# == Class: profiles::svc_nfs_server
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
class profiles::svc_nfs_server {

  # Add default group and users
  group { 'dlib' :
    ensure => present,
    gid    => '200',
  }

  ensure_packages([
    'nfs-utils',
    'rpcbind',
    'nfs4-acl-tools',
  ],{ 'ensure' => 'present' } )
  

}
