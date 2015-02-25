# == Class: nodejs
#
# Installs nodejs and npm.
#
class nodejs {
  package { ['nodejs',
             'nodejs-legacy',
             'npm']:
    ensure => installed
  }
}
