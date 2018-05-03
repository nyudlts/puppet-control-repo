# == Class: profile::cms_tct
#
# Full description of class profile here.
#
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#


class profiles::webapp_tct(
  String $allowed_hosts = lookup('tct::allowed_hosts', String, 'first'),
  String $backend       = lookup('tct::backend', String, 'first'),
  String $basename      = lookup('tct::basename', String, 'first'),
  String $baseurl       = lookup('tct::baseurl', String, 'first'),
  String $db_host       = lookup('tct::db_host', String, 'first'),
  String $db_password   = lookup('tct::db_password', String, 'first'),
  String $db_user       = lookup('tct::db_user', String, 'first'),
  String $media_root    = lookup('tct::media_root', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
  String $frontend      = lookup('tct::frontend', String, 'first'),
  String $install_dir   = lookup('tct::install_dir', String, 'first'),
  String $pub_src       = lookup('tct::pub_src', String, 'first'),
  String $secret_key    = lookup('tct::secret_key', String, 'first'),
  String $static_root   = lookup('tct::static_root', String, 'first'),
  String $tct_db        = lookup('tct::tct_db', String, 'first'),
  String $user          = lookup('tct::user', String, 'first'),
  String $venv_dir      = lookup('tct::venv_dir', String, 'first'),
  String $www_dir       = lookup('tct::www_dir', String, 'first'),
) {

  include housekeeping::packages


  ensure_packages(['rh-ruby22-ruby'], {'ensure' => 'present'})

  class { 'ruby':
    version         => 'rh-ruby22-ruby',
    gems_version    => 'latest',
    rubygems_update =>  true,
  }
  include ruby::dev
  class { 'ruby::gemrc' :
    gem_command => {
      'gem'     => [ 'no-document' ],
    }
  }

  file { 'rh-ruby22.sh' :
    ensure  => file,
    path    => '/etc/profile.d/rh-ruby22.sh',
    content => template('profiles/rh-ruby22.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
  ensure_packages(['psych'], {'ensure' => '2.2.4', 'provider' => 'gem'})

  include dltsyumrepo::el7::test

  group {'dlib' :
    ensure => present,
    gid    => '200',
  }

  include tct

   #file { '/run/nginx':
  #  ensure => directory,
  #  owner  => 'nginx',
  #  group  => 'nginx',
  #}
  include nginx
  nginx::resource::upstream { 'django' :
    ensure  => present,
    #members => [ 'unix:///tmp/nyu.sock', ],
    #members => [ 'unix:///run/uwsgi/nyu.sock', ],
    members => [ 'unix:///tmp/nyu.sock', ],
  }

  #file { 'uwsgi_params' :
  #  ensure  => file,
  #  owner   => 'nginx',
  #  group   => 'nginx',
  #  content => template('tct/uwsgi_params.erb'),
  #}

  #nginx::resource::server { '172.28.128.6/tct':
  #nginx::resource::server { 'www.tct2.org':
  #nginx::resource::server { '192.168.50.99':
  nginx::resource::server { "$basename" :
    # www_root => '/var/www/html/dist.prod',
  #  proxy        => 'http://localhost:54506',
  #uwsgi   => 'unix:/run/uwsgi/tct.sock',
  #  uwsgi   => 'unix:/run/uwsgi/nyu.sock',
    listen_options => 'default_server',
    uwsgi          => 'django',
    uwsgi_params   => '/etc/nginx/uwsgi_params',
  }

  ##
  # media_root, epubs_src_folder, and static_root are created
  # in inatall::backend. It's a bit confusing to leave it there,
  # but that's where is is for now.
  ##
  nginx::resource::location { '/media'  :
    location_alias => $media_root,
    server         => $basename,
    require        => [ File[$media_root], File["$epubs_src_folder"], ],
  }
  nginx::resource::location { '/static' :
    location_alias => $static_root,
    server         => $basename,
    require        => File["$static_root"],
  }
  # I thought that /tct should get everything that the bower server
  # gets, but I guess not
  nginx::resource::location { '/tct' :
    location_alias => "/var/www/html/dist.prod",
    server         => $basename,
  }

  nginx::resource::location { '/src' :
    location_alias => "/var/www/html/src",
    server         => $basename,
  }

  # uwsgi

    # create directories for uwsgi
  file { '/run/uwsgi' :
    ensure  => directory,
    owner   => $user,
    group   => 'nginx',
    mode    => '0775',
    require => Class['nginx'],
  }
  file { '/var/log/uwsgi' :
    ensure => directory,
    owner  => $user,
    group  => 'nginx',
    mode   => '0775',
    require => Class['nginx'],
  }
  file { '/var/log/uwsgi/nyu.log' :
    ensure => file,
    owner  => $user,
    group  => 'nginx',
    mode   => '0664',
  }

  # Install uwsgi
  python::pip { 'uwsgi':
    ensure     => latest,
    pkgname    => 'uwsgi',
    virtualenv => $venv_dir,
    owner      => 'root',
    timeout    =>  1800,
    environment => 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-python35/root/usr/lib64/',
  }

  # Load the uwsgi application config file
  #file { 'myapp.ini' :
  #  ensure  => file,
  #  owner   => $user,
  #  group   => 'nginx',
  #  path    => "${install_dir}/uwsgi/myapp.ini",
  #  content => template('tct/myapp.ini.erb'),
  #}
  alert("install_dir: $install_dir")
  alert("backend: $backend")
  $uwsgi_ini = "enm_uwsgi.ini"
  file { $uwsgi_ini :
    ensure  => file,
    owner   => $user,
    group   => 'nginx',
    path    => "${install_dir}/${backend}/$uwsgi_ini",
    #path    => "${install_dir}/${backend}/enm_uwsgi.ini",
    content => template('tct/enm_uwsgi.ini.erb'),
    require    => [ Python::Pip['uwsgi'], File['/etc/systemd/system/uwsgi.service'], File['/var/log/uwsgi/nyu.log'], File['/run/uwsgi'], Class['nginx'], ],
  }
  # Load the wsgi script
  #file { 'wsgi.py' :
  #  ensure  => file,
  #  path    => "${install_dir}/uwsgi/wsgi.py",
  #  content => template('tct/wsgi.py.erb'),
  #  require => File['myapp.ini'],
  #}
  file { '/etc/systemd/system/uwsgi.service' :
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content =>  template('tct/uwsgi.service.erb'),
  }
  service { 'uwsgi' :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    provider   => 'systemd',
    require    => [ Python::Pip['uwsgi'], File['/etc/systemd/system/uwsgi.service'], File["$uwsgi_ini"], File['/var/log/uwsgi/nyu.log'], File['/run/uwsgi'], ],
  }

  firewall { '100 allow nginx access on 80' :
    dport  => [80, 443, 8080, 9000],
    proto  => tcp,
    action => accept,
  }

}
