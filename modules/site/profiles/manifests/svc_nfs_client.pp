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
#https://www.cyberciti.biz/faq/centos-fedora-rhel-nfs-v4-configuration/
class profiles::svc_nfs_client {


  # Add default group and users
  group { 'dlib' :
    ensure => present,
    gid    => '200',
  }

  file { '/nfs1' :
    ensure => directory,
    owner  => 'root',
    group  => 'dlib',
    mode   => '0775',
  }
  file_line { '/etc/hosts' :
    path => '/etc/hosts/',
    line =>  '192.168.250.10 nfs-server.local',
  }
  file_line { '/etc/fstab' :
    path =>  '/etc/fstab',
    line => 'nfs-server.local:/nfs1 /nfs1 nfs4 soft,intr,rsize=8192,wsize=8192,nosuid',
  }

}
