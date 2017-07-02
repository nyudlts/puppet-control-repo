# define vim::plugin
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
#define vim::setup(
#  String $home = lookup('vim::home'),
#  String $vim_user = '$title',
#  String $vimrc = "$home/${title}/.vimrc"
#){

define vim::plugin (
  #String $home = lookup('vim::home'),
  String $plugin = $title,
  String $vim_group = 'staff',
  String $vimuser = $identity['user'],
  user
  String $home_dir = "${home}/${user}",
){

  notice("From the defined type: $title")
  file_line { "$title" :
    ensure => present,
    path   => "${home_dir}/.vimrc",
    #path   => "/tmp/vimrc",
    line   => "Plugin \'${title}\'",
    after  => "^Plugin \'gmarik/Vundle.vim\'"
  }
}
