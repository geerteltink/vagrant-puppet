# == Class: nodejs
#
# Installs nodejs, npm and git.
#
class nodejs {
  package { ['nodejs', 'npm', 'git-core']:
    ensure => present
  }
}
