# Class: tct::install::nginx
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
class tct::install::nginx (
  String $allowed_hosts = lookup('tct::allowed_hosts', String, 'first'),
  String $backend       = lookup('tct::backend', String, 'first'),
  String $basname       = lookup('tct::basename', String, 'first'),
  String $baseurl       = lookup('tct::baseurl', String, 'first'),
  String $db_host       = lookup('tct::db_host', String, 'first'),
  String $db_password   = lookup('tct::db_password', String, 'first'),
  String $db_user       = lookup('tct::db_user', String, 'first'),
  String $frontend      = lookup('tct::frontend', String, 'first'),
  String $install_dir   = lookup('tct::install_dir', String, 'first'),
  String $media_root    = lookup('tct::media_root', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
  String $secret_key    = lookup('tct::secret_key', String, 'first'),
  String $static_root   = lookup('tct::static_root', String, 'first'),
  String $tct_db        = lookup('tct::tct_db', String, 'first'),
  String $user          = lookup('tct::user', String, 'first'),
  String $www_dir       = lookup('tct::www_dir', String, 'first'),
){

  include nginx
  nginx::resource::server { 'tct.home.wfc':
    www_root =>  '/var/www/html',
  }
    
  firewall { '100 allow apache access on 80' :
    dport  => [80, 443],
    proto  => tcp,
    action => accept,
  }

}
