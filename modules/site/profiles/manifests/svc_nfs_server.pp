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

  ensure_packages({
    'nfs-utils'      => { ensure => present },
    'rpcbind'        => { ensure => present },
    'nfs4-acl-tools' => { ensure => present },
  }, { 'ensure' => 'present' } )

  file_line { 'export_nfs1' :
    path => '/etc/exports',
    line =>  '/nfs1  192.168.250.11(rw,sync,fsid=0)',
  }

  service { 'nfs' :
    enable =>  true,
    ensure => running,
  }
    
  file_line { '/etc/hosts' :
    path => '/etc/hosts/',
    line =>  '192.168.250.11 nfs-client.local',
  }

  firewall { '100 allow nfs access on 2049' :
    dport  => [2049,],
    proto  => tcp,
    action => accept,
    source => '192.168.250.11',
  }


}
