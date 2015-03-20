define apt::ppa (
    $repository = $title,
    $release    = $::lsbdistcodename,
    $options    = $::apt::params::ppa_options
) {

    include apt::params
    include apt::update

    $sources_list_d = $apt::params::sources_list_d

    $filename_without_slashes = regsubst($repository, '/', '-', 'G')
    $filename_without_dots    = regsubst($filename_without_slashes, '\.', '_', 'G')
    $filename_without_ppa     = regsubst($filename_without_dots, '^ppa:', '', 'G')
    $sources_list_d_filename  = "${filename_without_ppa}-${release}.list"

    if $::operatingsystem != 'Ubuntu' {
        fail('apt::ppa is currently supported on Ubuntu only.')
    }

    exec { "add-apt-repository-${repository}":
        command     => "add-apt-repository ${options} ${repository}",
        creates     => "${sources_list_d}/${sources_list_d_filename}",
        logoutput   => 'on_failure',
        notify      => Exec['apt-update']
    }
}
