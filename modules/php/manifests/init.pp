# == Class: php
#
# Installs PHP5 and necessary modules. Sets config files.
#
class php {
  package { ['php5-cli',
             'php5-fpm',
             'php5-curl',
             'php5-gd',
             'php5-intl',
             'php5-mcrypt',
             'php5-mysql',
             'php5-sqlite',
             'php5-xdebug']:
    ensure => present;
  }

  service { 'php5-fpm':
    ensure  => running,
    require => Package['php5-fpm']
  }

  file {
    '/etc/php5/cli':
      ensure => directory,
      before => File ['/etc/php5/cli/php.ini'];

    '/etc/php5/cli/php.ini':
      source  => 'puppet:///modules/php/php-cli.ini',
      require => Package['php5-cli'];

    '/etc/php5/fpm':
      ensure => directory,
      before => File ['/etc/php5/fpm/php.ini'];

    '/etc/php5/fpm/php.ini':
      source  => 'puppet:///modules/php/php-fpm.ini',
      require => Package['php5-fpm'];
  }

  exec { 'enable-mcrypt':
    command => 'php5enmod mcrypt',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
    require => Package['php5-mcrypt'],
    notify => Service['php5-fpm'];
  }

  exec { 'enable-pdo-mysql':
    command => 'php5enmod pdo_mysql',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
    require => Package['php5-fpm', 'php5-mysql'],
    notify => Service['php5-fpm'];
  }
}
