# == Class: nodejs
#
# Installs nodejs, npm and git.
#
class nodejs {
  package { ['nodejs',
             'nodejs-legacy',
             'npm',
             'git-core']:
    ensure => present
  }
}
