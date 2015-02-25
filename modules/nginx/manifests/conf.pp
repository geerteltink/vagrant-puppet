# == Define: conf
#
# Adds an nginx configuration file.
#
define nginx::conf() {
  file { "/etc/nginx/${name}":
    source  => "puppet:///modules/nginx/${name}",
    require => Package['nginx'],
    notify  => Service['nginx'];
  }
}
