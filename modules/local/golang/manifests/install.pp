#
class golang::install {

  ensure_packages(['golang'], {'ensure' => 'present'})

  if $facts['virtual'] == 'virtualbox' {
    $users = ['root', 'vagrant']
  }
  $users.each |String $users| {
    golang::env{ $users : }
  }
}
