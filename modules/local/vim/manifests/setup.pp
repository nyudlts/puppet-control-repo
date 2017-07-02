# define vim::setup
# ===========================
#
# Full description of class vim here.
#
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
#  String $vim_home = "${home}/${vim_user}",
define vim::setup(
  String $home = lookup('vim::home'),
  String $vim_user = '$title',
  String $vimrc = "$home/${title}/.vimrc"
){

  file_line { 'alias_vi' :
    ensure => present,
    path   => "${home}/${title}/.bashrc",
    line   => 'alias vi=vim',
  }

  #exec { 'PluginInstall' :
  #  command => '/usr/local/bin/vim +PluginInstall +qall 2>&1 1> /dev/null',
  #  path    => '/usr/local/bin',
  #}

  #exec { 'git_editor' :
  #  command => 'git config --global core.editor $(which vim)',
  #  path => [ "/usr/local/bin/git", "/usr/bin" ],
  #}


  notice("From the defined type: $title")

  #$vimrc = "$home/${title}/.vimrc"
  concat { $vimrc :
    owner => $title,
    group => $title,
    mode    => '0644',
    replace => true,
  }
  #file { $vimrc :
  #  ensure  => file,
  #  owner   => $title,
  #  group   => $title,
  #  mode    => '0644',
  #  replace =>  true,
  #}
  concat::fragment{ 'vimrc_header':
    target => $vimrc,
    source => "puppet:///modules/vim/vimrc_header",
    order  => '01',
  }
  concat::fragment{ 'vimrc_colorscheme':
    target => $vimrc,
    source => "puppet:///modules/vim/vimrc_colorscheme",
    order  => '02',
  }
  concat::fragment{ 'vimrc_footer':
    target => $vimrc,
    source => "puppet:///modules/vim/vimrc_footer",
    order  => '03',
  }
}
