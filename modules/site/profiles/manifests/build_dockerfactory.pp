class profiles::build_dockerfactory {

  #include java
  class { 'java':
    package => 'java-1.8.0-openjdk-devel',
  }
  #include pyenv
  #pyenv::install { ['vagrant','root']: }
  #pyenv::compile { 'compile 2.7.11 root' :
  #  user   => 'root',
  #  python => '2.7.11',
  #  global => true,
  #}
  #pyenv::compile { 'compile 2.7.11 vagrant' :
  #  user    => 'vagrant',
  #  python  => '2.7.11',
  #  global  => true,
  #}

  include docker
  group { 'docker':
    members => ['vagrant'],
    require => Class['docker'],
  }
}

