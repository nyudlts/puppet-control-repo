class roles::test_rvm {
  include profiles::base
  include profiles::rvm
  include profiles::rvm::test
}
