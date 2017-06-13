class roles::tct {
  include profiles::base
  include profiles::db_postress
  include profiles::cms_tct
  include profiles::rbenv
}
