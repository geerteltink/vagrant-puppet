class git (
    $push_default = $git::params::push_default,
    $user_name    = $git::params::user_name,
    $user_email   = $git::params::user_email
) inherits git::params {

    apt::ppa { 'ppa:git-core/ppa': }
    apt::key { 'E1DD270288B4E6030699E45FA1715D88E1DF1F24': }

    package { 'git':
        ensure => latest
    }

    file { '/home/vagrant/.gitconfig':
        content => template('git/gitconfig.erb'),
        owner => 'vagrant',
        group => 'vagrant',
        mode  => '0664',
        require => Package['git']
    }
}
