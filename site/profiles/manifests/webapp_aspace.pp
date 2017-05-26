# == Class: profile::webapp_aspace_migration
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
class profiles::webapp_aspace {

#
class profiles::webapp_aspace_migrate (
  $db          = hiera('archivesspace::db',
      $archivesspace::params::db),
  $db_passwd   = hiera('archivesspace::db_passwd',
      $archivesspace::params::db_passwd),
  $db_user     = hiera('archivesspace::db_user',
      $archivesspace::params::db_user),
  $install_dir = $archivesspace::params::install_dir,
  $user        = hiera('archivesspace::user',
      $archivesspace::params::user),

) inherits archivesspace::params {

  # Add default group and users
  group { 'dlib' :
    ensure   => present,
    gid      => '200',
  }
  accounts::account { 'flannon' : }
  accounts::account { 'sally' : }

  file_line { 'sudo_rule_nopw':
    path => '/etc/sudoers',
    line => '%dlib    ALL=(ALL)   NOPASSWD: ALL',
  }

  include dltsyumrepo::development
  class { 'java':
    package => 'java-1.8.0-openjdk',
  }
  #include archivesspace
  #archivesspace::plugin { 'barcoder' :
  #  ensure        => 'present',
  #  plugin        => 'barcoder',
  #  plugin_source => 'https://github.com/archivesspace/barcoder.git',
  #  plugin_conf   => 'AppConfig[:plugins] = [\'barcoder\']',
  #}

  #archivesspace::plugin { 'nyu_marcxml_export_plugin' :
  #  ensure        => 'absent',
  #  plugin        => 'nyu_marcxml_export_plugin',
  #  plugin_source => 'https://github.com/NYULibraries/nyu_marcxml_export_plugin.git',
  #  plugin_conf   => 'AppConfig[:plugins] = [\'nyu_marcxml_export_plugin\']'
  #}

  firewall { '100 allow http and https access':
    dport  => [ 80, 8080, 8081, 8089, 8090, 8091 ],
    proto  => tcp,
    action => accept,
  }
  firewall { '102 forward port 80 to 8080':
    table   => 'nat',
    chain   => 'PREROUTING',
    iniface => 'eth0',
    proto   => 'tcp',
    dport   => '80',
    jump    => 'REDIRECT',
    toports => 8080,
  }
  # set up the db
  include profiles::db_mysql
  mysql::db { 'asdb' :
    user     => $db_user,
    password => $db_passwd,
    dbname   => 'asdb',
    host     => 'localhost',
    grant    => [ 'ALL' ],
    #notify   => Class['archivesspace'],
  }
  #Class['profiles::db_mysql']->Class['archivesspace']

}

}
