class phpmyadmin (
    $install_path = $phpmyadmin::params::install_path,
    $version      = $phpmyadmin::params::version,
    $secret       = $phpmyadmin::params::secret
) inherits phpmyadmin::params {

    $release_name = "RELEASE_${version}"
    $target = "${$install_path}/phpmyadmin-${release_name}"
    $source = "https://github.com/phpmyadmin/phpmyadmin/archive/${release_name}.tar.gz"

    if ! defined(Package['wget']) {
        package { 'wget': ensure => installed }
    }

    file { '/var/phpmyadmin':
        ensure => directory
    }

    exec { 'phpmyadmin-retrieve':
        command => "wget $source -O /var/phpmyadmin/${release_name}.tar.gz",
        creates => "/var/phpmyadmin/${release_name}.tar.gz",
        require => Package['wget']
    }

    exec { 'phpmyadmin-unpack':
        command => "tar -xvzf /var/phpmyadmin/${release_name}.tar.gz -C ${install_path}",
        creates => "${target}"
    }

    file { 'phpmyadmin-conf':
        path    => '/etc/apache2/sites-available/20-phpmyadmin.conf',
        content => template('phpmyadmin/_header.erb', 'phpmyadmin/phpmyadmin.conf.erb'),
        mode    => '0644',
        notify  => Service['apache2']
    }

    file { 'phpmyadmin-ini':
        path    => "${target}/config.inc.php",
        content => template('phpmyadmin/config.inc.php.erb'),
        mode    => '0644',
        notify  => Service['apache2']
    }

    file { 'phpmyadmin-enable':
        ensure => 'link',
        path   => '/etc/apache2/sites-enabled/20-phpmyadmin.conf',
        target => '/etc/apache2/sites-available/20-phpmyadmin.conf',
        notify  => Service['apache2']
    }

    # Dependencies
    File['/var/phpmyadmin'] ->
    Exec['phpmyadmin-retrieve'] ->
    Exec['phpmyadmin-unpack'] ->
    File['phpmyadmin-conf'] ->
    File['phpmyadmin-enable']
}
