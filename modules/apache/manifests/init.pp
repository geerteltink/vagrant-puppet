class apache {
  package { ['apache2',
             'apache2-mpm-worker']:
    ensure => present
  }

  service { 'apache2':
    ensure  => running,
    require => Package['apache2']
  }

  file {
    '/var/www':
      ensure => 'link',
      target => '/vagrant',
      require => Package['apache2'],
      notify => Service['apache2'],
      replace => yes,
      force => true;

    '/var/www/html':
      ensure => 'absent',
      force => true;

    '/etc/apache2/sites-enabled/000-default.conf':
      ensure  => link,
      target  => '/etc/apache2/sites-available/000-default.conf',
      require => Package['apache2', 'php5-fpm', 'phpmyadmin'],
      notify  => Service['apache2'];
  }

  exec { 'enable modules':
    command     => '/usr/sbin/a2enmod rewrite proxy_fcgi',
    require     => Package['apache2'],
    notify      => Service['apache2']
  }

  apache::conf { ['apache2.conf',
                  'envvars',
                  'ports.conf',
                  'sites-available/000-default.conf']:
    require     => Package['apache2'],
    notify      => Service['apache2']
  }
}
