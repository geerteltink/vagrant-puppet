class core::bash (
) {

    file { '/home/vagrant/.bashrc':
        content => template('core/bashrc.erb'),
        owner => 'vagrant',
        group => 'vagrant',
        mode  => '0644'
    }
}
