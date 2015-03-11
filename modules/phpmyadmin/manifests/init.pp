# == Class: phpmyadmin
#
# Installs PhpMyAdmin and sets config file.
#

class phpmyadmin {

  package { 'phpmyadmin':
    ensure => latest,
  }

  file {
    '/etc/phpmyadmin/config.inc.php':
      content => template('phpmyadmin/config.inc.php.erb'),
      owner => 'root',
      group => 'root',
      mode  => '0644',
      require => Package['phpmyadmin'];
  }
}
