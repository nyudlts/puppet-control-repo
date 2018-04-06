class roles::lamp {
  include profiles::base
  include profiles::db_mysql
  include profiles::web_apache
}
