#
function vim::params(
  Hash          $options,
  Puppet::LookupContext $context,
) {

  $base_params = {
    'vim::ensure' => 'present',
  }
  
  $virtual_params = case $facts['virtual'] {
    'xenu': { 
      case $facts['os']['family'] {
        'RedHat': {
          case $facts['os']['release']['major'] {
            '7': {
              alert("centos7 running on aws")
              $default_user = 'centos' 
            }
            default: {
              fail( "${facts['os']} ${facts['os']['release']['major']} is not supported at this time" )
            }
          }
        }
        default: {
          fail( "${facts['os']} ${facts['os']['release']} is not supported at this time" )
        }
      }
    } # end xenu
    'xenhvm': { 
      case $facts['os']['family'] {
        'RedHat': {
          case $facts['os']['release']['major'] {
            '7': {
              alert("centos7 running on aws")
              $default_user = 'centos' 
            }
            default: {
              fail( "${facts['os']} ${facts['os']['release']['major']} is not supported at this time" )
            }
          }
        }
        default: {
          fail( "${facts['os']} ${facts['os']['release']} is not supported at this time" )
        }
      }
    } # end xenhvm
    'virtualbox': { 
      case $facts['os']['family'] {
        'RedHat': {
          case $facts['os']['release']['major'] {
            '7': {
              alert("centos7 running on aws")
              $default_user = 'centos' 
              $home = '/home'
            }
            default: {
              fail( "${facts['os']} ${facts['os']['release']['major']} is not supported at this time" )
            }
          }
        }
        default: {
          fail( "${facts['os']} ${facts['os']['release']} is not supported at this time" )
        }
      }
    } # end virtualbox
    'physical': {
      case $facts['os']['family'] {
        'Darwin': {
          alert("osfamily - $os.family")
          $group = 'staff'
          $home  = '/Users'
        }
        default: {
          fail("Physical platform ${facts['virtual']} is not supported at this time")
        }
      }
    }
    default:  {
      fail("Virtualization platform ${facts['virtual']} is not supported at this time")
    }
  }

  $base_params + $virtual_params
  #case $facts['os']['family'] {
  #  'RedHat': {
  #    case $facts['os']['release']['major'] {
  #      '7': {
  #        case $facts['virtual'] {
  #          'xenu':       { $user = 'centos' }
  #          'xenhvm':     { $user = 'centos' }
  #          'virtualbox': { $user = 'vagrant' }
  #          default:  {
  #            fail("Virtualization platform ${facts['virtual']} is not supported at this time")
  #          }
  #        } # End case 3
  #      }
  #      default: {
  #        fail( "${facts['os']} ${facts['os']['release']['major']} is not supported at this time" )
  #      }
  #    } # End case 2
  #  }
  #  default: {
  #    fail( "${facts['os']} ${facts['os']['release']['major']} is not supported at this time" )
  #  }
  #} # End case
}
