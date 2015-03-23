define apt::source (
    $comment           = $name,
    $ensure            = present,
    $location          = '',
    $release           = $::lsbdistcodename,
    $repos             = 'main',
    $include_src       = true,
    $include_deb       = true,
    $required_packages = false,
    $key               = undef,
    $key_server        = 'keyserver.ubuntu.com',
    $key_content       = undef,
    $key_source        = undef,
    $pin               = false,
    $architecture      = undef,
    $trusted_source    = false,
) {

    include apt::params
    include apt::update

    validate_string($architecture)
    validate_bool($trusted_source)

    $sources_list_d = $apt::params::sources_list_d

    file { "${name}.list":
        ensure  => $ensure,
        path    => "${sources_list_d}/${name}.list",
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('apt/_header.erb', 'apt/source.list.erb'),
        notify  => Exec['apt-update']
    }

    if ($required_packages != false) and ($ensure == 'present') {
        exec { "Required packages: '${required_packages}' for ${name}":
            command     => "apt-get -y install ${required_packages}",
            logoutput   => 'on_failure',
            refreshonly => true,
            tries       => 3,
            try_sleep   => 1,
            subscribe   => File["${name}.list"],
            before      => Exec['apt-update']
        }
    }

    if $key and ($ensure == 'present') {
        apt::key { "${key}": }
    }
}
