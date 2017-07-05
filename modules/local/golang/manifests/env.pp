#
define golang::env {
  if $title == 'root' {
    $userhome = "/${title}"
  }
  else {
    $userhome = "/home/$title"
  }

  file_line { "${userhome} goroot":
    path => "${userhome}/.bashrc",
    line => 'export GOROOT=/usr/lib/golang',
  }
  file { "${userhome}/projects" :
    ensure => directory,
    owner  => $user,
    group  => $user,
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
