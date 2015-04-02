# class: webhook::params
#
# this class manages webhook puppet parameters
#
# parameters:
#
# actions:
#
# requires:
#
# sample usage:
#
class webhook::params {

  $homedir  = '/opt/webhook'
  $port     = '81'
  $owner    = 'root'
  $group    = 'root'
  $mco      = 'false' # Important, since we are writing to a json file and Json only do lowercase boolean.
  $mco_user = 'mcollective-user' # the user being utilized to invoke mco r10k

  # OS specific stuff
  if $::osfamily == 'RedHat' {
    $ruby_dev = 'ruby-devel'
  } elsif $::osfamily == 'Debian' {
    $ruby_dev = 'ruby-dev'
  }

}
