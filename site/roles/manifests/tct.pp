class roles::tct {
  include profiles::base
  include profiles::db_postgres
  include profiles::cms_tct
  include profiles::rbenv
}
