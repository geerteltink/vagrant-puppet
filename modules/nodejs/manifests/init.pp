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

  exec { 'npm-bower':
    command => 'npm install bower -g',
    path    => ['/usr/bin'],
    require => Package['nodejs-legacy', 'npm'];
  }

  exec { 'npm-gulp':
    command => 'npm install gulp -g',
    path    => ['/usr/bin'],
    require => Package['nodejs-legacy', 'npm'];
  }

  exec { 'npm-less':
    command => 'npm install less -g',
    path    => ['/usr/bin'],
    require => Package['nodejs-legacy', 'npm'];
  }

  exec { 'npm-uglifycss':
    command => 'npm install uglifycss -g',
    path    => ['/usr/bin'],
    require => Package['nodejs-legacy', 'npm'];
  }

  exec { 'npm-uglify-js':
    command => 'npm install uglify-js -g',
    path    => ['/usr/bin'],
    require => Package['nodejs-legacy', 'npm'];
  }

  exec { 'npm-jshint':
    command => 'npm install jshint -g',
    path    => ['/usr/bin'],
    require => Package['nodejs-legacy', 'npm'];
  }
}
