# == Class: apache
#
# Installs packages for nginx and sets config files.
#
class nginx {
  # Remove apache
  package { 'apache2':
    ensure => purged,
    notify => Exec['autoremove']
  }
  exec { 'autoremove':
    command => '/usr/bin/apt-get autoremove --purge -y',
    refreshonly => true
  }

  package { ['nginx']:
    ensure => installed
  }

  service { 'nginx':
    ensure  => running,
    require => Package['nginx']
  }

  nginx::conf {
    ['sites-available/default']:
  }
}
