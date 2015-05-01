class core::bash (
) {

    file { '/home/vagrant/.bashrc':
        content => template('core/bashrc.erb'),
        owner => 'vagrant',
        group => 'vagrant',
        mode  => '0644'
    }

    file { '/home/vagrant/.bash_profile':
        content => template('core/bash_profile.erb'),
        owner => 'vagrant',
        group => 'vagrant',
        mode  => '0644'
    }
}
