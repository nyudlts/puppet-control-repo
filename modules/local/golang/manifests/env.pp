#
define golang::env {
  if $title == 'root' {
    $userhome = "/${title}"
  }
  else {
    $userhome = "/home/$title"
  }

  file { "/usr/local/go" :
    ensure => directory,
    #owner  => $user,
    #group  => $user,
    owner  => 'vagrant',
    group  => 'vagrant',
    mode   => '0755',
  }
  file_line { "${userhome} goroot":
    path => "${userhome}/.bashrc",
    line => 'export GOROOT=/usr/local/go',
  }
  file { "${userhome}/projects" :
    ensure => directory,
    #owner  => $user,
    #group  => $user,
    owner  => 'vagrant',
    group  => 'vagrant',
    mode   => '0755',
  }
  file_line { "${userhome} gopath":
    path => "${userhome}/.bashrc",
    line => "export GOPATH=${userhome}/projects",
  }
  file_line { "${userhome} userpath":
    path => "${userhome}/.bashrc",
    line => 'export PATH=$GOPATH/bin:%GOROOT/bin:$PATH',
  }
}
