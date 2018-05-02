class profiles::webapp_composers {
  
  include housekeeping

  ensure_packages(['nano'], {'ensure' => 'present'})

  class { 'nginx': }

  nginx::resource::server { 'localhost':
    listen_port => 80,
  }

  class { 'java' :
    package => 'java-1.8.0-openjdk-devel',
  }

  class { 'sbt':
    sbt_jar_version  => '0.13.11',
  	sbt_java_opts    => '-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M',
  	sbt_jar_path     => '/bin',
  }

  file { "/vagrant/composers-demo" :
    ensure => directory,
    owner => "vagrant",
    group => "vagrant",
    mode => "0755",
  }

  vcsrepo { '/vagrant/composers-demo':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/NYULibraries/Composers-API-Demo.git',
    owner => "vagrant",
    group => "vagrant",
  }

  firewall { '100 allow rails port access':
    dport   => 8080,
    proto   => tcp,
    action  => accept,
  }
}