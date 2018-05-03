# Class: tct::install::backend
# ===========================
#
# Full description of class tct here.
#
#
# Examples
# --------
#
#
# Authors
# -------
#
# Flannon Jackson <flannon@nyu.edu>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class tct::install::backend (
  String $allowed_hosts    = lookup('tct::allowed_hosts', String, 'first'),
  String $backend          = lookup('tct::backend', String, 'first'),
  String $backend_revision = lookup('tct::backend_revision', String, 'first'),
  String $basename         = lookup('tct::basename', String, 'first'),
  String $baseurl          = lookup('tct::baseurl', String, 'first'),
  String $db_host          = lookup('tct::db_host', String, 'first'),
  String $db_password      = lookup('tct::db_password', String, 'first'),
  String $db_user          = lookup('tct::db_user', String, 'first'),
  String $django_user      = lookup('tct::django_user', String, 'first'),
  String $frontend         = lookup('tct::frontend', String, 'first'),
  String $install_dir      = lookup('tct::install_dir', String, 'first'),
  String $media_root       = lookup('tct::media_root', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
  String $pub_src          = lookup('tct::pub_src', String, 'first'),
  String $secret_key       = lookup('tct::secret_key', String, 'first'),
  String $static_root      = lookup('tct::static_root', String, 'first'),
  String $tct_db           = lookup('tct::tct_db', String, 'first'),
  String $user             = lookup('tct::user', String, 'first'),
  String $venv_dir         = lookup('tct::venv_dir', String, 'first'),
  String $www_dir          = lookup('tct::www_dir', String, 'first'),
){

    # clone the backend
  vcsrepo { "${install_dir}/${backend}":
    ensure   => present,
    provider => git,
    source   => "https://github.com/NYULibraries/dlts-enm-tct-backend",
    revision => $backend_revision,
  }

  # set up postgres
  include postgresql::server
  include postgresql::lib::devel
  include postgresql::lib::python
  postgresql::server::db { $tct_db:
    user     => $db_user,
    password => postgresql_password($db_user, $db_password),
  }->
  postgresql::server::role { 'tct_role':
    password_hash => postgresql_password('tct_role', '$db_password'),
  }->
  postgresql::server::database_grant {$db_user:
    privilege => 'ALL',
    db        => $tct_db,
    role      => 'tct_role',
  }

  # Load backend database production_settings
  file { 'production_settings.py':
    ensure  => file,
    path    => "${install_dir}/${backend}/nyu/production_settings.py",
    require => Vcsrepo["${install_dir}/${backend}"],
    content => template('tct/production_settings.py.erb'),
  }
  file { 'secretkeys.json':
    ensure  => file,
    path    => "${install_dir}/${backend}/nyu/secretkeys.json",
    require => [ Vcsrepo["${install_dir}/${backend}"], Class['postgresql::server'], ],
    content => template('tct/secret_keys.json.erb'),
  }
  file { '/var/log/django':
    ensure => directory,
    owner  => $django_user,
    group  => $django_user,
    mode   => '0777',
  }
  file { '/var/log/django/nyu.log':
    ensure => file,
    owner  => $django_user,
    group  => $django_user,
    mode   => '0666',
  }
  file { "$pub_src":
  #file { "${install_dir}/www":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }
  file { "$pub_src/$basename":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }
  file { $media_root:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }
  file { $epubs_src_folder:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
    require => [ Vcsrepo["${install_dir}/${backend}"], Class['postgresql::server'], File["$media_root"], ],
  }
   file { "$static_root" :
     ensure => directory,
     owner  => $user,
     group  => $user,
     mode   => "0755",
   }


  # Run the python installer,
  #  python manage.py loaddata indexpatterns.json
  # see: dlts-enm-tct-backend/documentation/site/setup/index.html

  exec { 'exec_manage_py_migrate':
    #path     => ['/opt/tct/venv/bin','/bin','/usr/bin','/usr/local/bin'],
    path     => ["${venv_dir}/bin",'/bin','/usr/bin','/usr/local/bin'],
    cwd      => "${install_dir}/${backend}",
    command  => 'python manage.py migrate',
    creates  => "${install_dir}/${backend}/reconciliation/__pycache__",
    environment => 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-python35/root/usr/lib64/',
    require  => [ File['secretkeys.json'], Python::Pyvenv["$venv_dir"], Python::Requirements["${install_dir}/etc/requirements.txt"], Class["postgresql::server"], Postgresql::Server::Database_grant["$db_user"], ],

    user     => 'root',
  }


}
