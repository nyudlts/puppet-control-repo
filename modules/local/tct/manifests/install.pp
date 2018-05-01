# Class: tct::install
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
class tct::install (
  String $allowed_hosts    = lookup('tct::allowed_hosts', String, 'first'),
  String $backend          = lookup('tct::backend', String, 'first'),
  String $backend_repo     = lookup('tct::backend_repo', String, 'first'),
  String $backend_revision = lookup('tct::backend_revision', String, 'first'),
  String $basname          = lookup('tct::basename', String, 'first'),
  String $baseurl          = lookup('tct::baseurl', String, 'first'),
  String $db_host          = lookup('tct::db_host', String, 'first'),
  String $db_password      = lookup('tct::db_password', String, 'first'),
  String $db_user          = lookup('tct::db_user', String, 'first'),
  String $frontend         = lookup('tct::frontend', String, 'first'),
  String $frontend_repo    = lookup('tct::frontend_repo', String, 'first'),
  String $frontend_revision = lookup('tct::backend_revision', String, 'first'),
  String $install_dir      = lookup('tct::install_dir', String, 'first'),
  String $media_root       = lookup('tct::media_root', String, 'first'),
  String $user             = lookup('tct::user', String, 'first'),
  String $secret_key       = lookup('tct::secret_key', String, 'first'),
  String $www_dir          = lookup('tct::www_dir', String, 'first'),
  String $static_root      = lookup('tct::static_root', String, 'first'),
  String $tct_db           = lookup('tct::tct_db', String, 'first'),
  String $venv             = lookup('tct::venv', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
 ){

  # Add third party package repos
  include ius

  # Add the user
  user { $user :
    ensure     => present,
    name       => $user,
    comment    => "Topic Curation Toolkit",
    home       => $install_dir,
    managehome => false,
  }

  file { $install_dir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  # Install the repos
  alert('Install backend repo')
  vcsrepo { "${install_dir}/${backend}":
    ensure   => present,
    provider => git,
    source   => $backend_repo,
    revision => $backend_revision,
  }
  vcsrepo { "${install_dir}/${frontend}":
    ensure   => present,
    provider => git,
    source   => $frontend_repo,
    revision => $frontend_revision,
  }

  #alert('Install backend repo - 1')

  # Install python3.5 from the RH community editions
  class { 'python':
    version                     => 'rh-python35-python',
    pip                         => 'present',
    dev                         => 'latest',
    virtualenv                  => 'present',
    gunicorn                    => 'absent',
    use_epel                    => true,
    rhscl_use_public_repository => true,
  }->
  file { 'rh-python35.sh' :
    ensure  => file,
    path    => '/etc/profile.d/rh-python35.sh',
    content => template('tct/rh-python35.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }->
  python::pip { 'pip':
    ensure     => latest,
    pkgname    => 'pip',
    virtualenv => 'system',
    owner      => 'root',
    timeout    => 1800,
  }->
  python::pip { 'virtualenv':
    ensure     => latest,
    pkgname     => 'virtualenv',
    virtualenv => 'system',
    owner      => 'root',
    timeout    => 1800,
  }->
  python::pip { 'setuptools':
    ensure     => latest,
    pkgname    => 'setuptools',
    virtualenv => 'system',
    owner      => 'root',
    timeout    => 1800,
  }->
  python::pip { 'psycopg2':
    ensure                            => '2.7.4',
    #ensure                            => latest,
    pkgname                           => 'psycopg2',
    #virtualenv                        => $venv,
    virtualenv                        => 'system',
    owner                             => 'root',
    timeout                           => 1800,
    environment                       => 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-python35/root/usr/lib64/',
    #require                          => Class['postgresql::server'],
  }

  #file { 'venv-dir' :
  #  ensure => 'directory',
  #  path   => $venv,
  #}
  file { "requirements.txt" :
    #path   => "/home/${user}/src/requirements.txt",
    ensure  => present,
    path    => "${venv}/requirements.txt",
    owner   => 'root',
    group   => 'root',
    mode    => "0644",
    source  => "puppet:///modules/tct/requirements.txt",
    #require => File[ "$venv" ],
  }
  python::pyvenv { $venv :
    ensure      => present,
    version     => '3.5',
    systempkgs  => true,
    venv_dir    => $venv,
    owner       => 'root',
    group       => 'root',
    path        => '/opt/rh/rh-python35/root/bin/:/bin:/usr/bin:/usr/local/bin',
    environment => 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-python35/root/usr/lib64/',
    require     => Class['python'],
  }->
  file { "${venv}/bin/pip" :
    ensure => link,
    target => '/opt/rh/rh-python35/root/bin/pip',
  }
  python::pip { 'uWSGI':
    ensure     => latest,
    pkgname    => 'uWSGI',
    virtualenv => $venv,
    owner      => 'root',
    timeout    =>  1800,
    environment => 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-python35/root/usr/lib64/',
  }
  python::requirements { "${venv}/requirements.txt":
    virtualenv                        => $venv,
    owner                             => 'root',
    group                             => 'root',
    environment                       => 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-python35/root/usr/lib64/',
    #require                           => [ File['requirements.txt'], Python::Pyvenv["${venv}"], ],
    require                           => File['requirements.txt'],
 }

 # Documentation
  #file { 'requirements-documentation.txt':
  #  ensure                            => present,
  #  path                              => "${venv}/requirements-documentaiton.txt",
  #  owner                             => 'root',
  #  group                             => 'root',
  #  mode                              => '0644',
  #  source                            => "puppet:///modules/tct/requirements-documentation.txt",
  #}
  #python::requirements { "${venv}/requirements-documentation.txt":
  #  virtualenv                        => $venv,
  #  owner                             => 'root',
  #  group                             => 'root',
  #  require                           => Python::Virtualenv["${venv}"],
  #}

  # Testing
  #file { "requirements-testing.txt" :
  #  ensure                            => present,
  #  path                              => "${venv}/requirements-testing.txt",
  #  owner                             => 'root',
  #  group                             => 'root',
  #  mode                              => '0644',
  #  source                            => "puppet:///modules/tct/requirements-testing.txt",
  #}
  
  #ensure_packages({'psych'            => { ensure => '3.0.2' } ,  'mypackage' => { source => '/tmp/myrpm-1.0.0.x86_64.rpm', provider => "rpm" }}, {'ensure' => 'present'})


  #package { 'pysch' :
  #  ensure   => '3.0.2',
  #  provider => 'gem',
  #  require => Package['rubygems'],
  #}

  alert('ENd of tct install')

}
