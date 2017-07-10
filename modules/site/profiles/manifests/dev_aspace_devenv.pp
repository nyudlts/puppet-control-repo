#
class profiles::aspace_dev {
  $install_dir = hiera('archivesspace_dev::install_dir', '/opt/archivesspace')
  $revision    = hiera('archivesspace_dev::revision', 'master')
  $source      = hiera('archivesspace_dev::source')
  $user        = hiera('archivesspace_dev::user', 'vagrant')
  $asdb_name   = hiera('mysql::asdb_name', 'asdb')
  $asdb_passwd = hiera('mysql::asdv_passwd', 'aspace')
  $asdb_user   = hiera('mysql::asdb_user', 'asdb')

  firewall { '100 allow http and https access':
      dport   => [3000, 3100, 4567, 8080, 8081,  8089, 8090, 8091 ],
      proto   => tcp,
      action  => accept,
  }
  include housekeeping
  #include java
  class { 'java':
    package => 'java-1.8.0-openjdk-devel',
  }
  class { 'archivesspace_dev' :
      install_dir => $install_dir,
      revision    => $revision,
      source      => $source,
      user        => $user,
  }
  include profiles::db_mysql
  mysql::db { 'asdb' :
    user     => $asdb_user,
    password => $asdb_passwd,
    dbname   => $asdb_name,
    host     => 'localhost',
    grant    => [ 'ALL' ],
  }

}
