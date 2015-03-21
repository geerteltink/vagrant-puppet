class composer (
    $target_dir     = $composer::params::target_dir,
    $composer_file  = $composer::params::composer_file,
    $frequency      = $composer::params::update_frequency,
    $tmp_path       = $composer::params::tmp_path,
    $php_package    = $composer::params::php_package,
) inherits composer::params {

    validate_integer($frequency)

    if ! defined(Package['wget']) {
        package { 'wget': ensure => installed }
    }

    # check if directory exists
    if defined(File[$target_dir]) == false {
        file { $target_dir:
            ensure => directory
        }
    }

    if defined(File["${target_dir}/${composer_file}"]) == false {
        exec { 'composer-download':
            command   => "wget $::composer::params::phar_location -O ${tmp_path}/composer.phar",
            cwd       => $tmp_path,
            require   => Package['wget', $php_package],
            creates   => "${tmp_path}/composer.phar",
            logoutput => 'on_failure'
        }
        # move file to target_dir
        file { "${target_dir}/${composer_file}":
            ensure    => present,
            source    => "${tmp_path}/composer.phar",
            require   => [ Exec['composer-download'], File[$target_dir] ],
            mode      => '0755'
        }
    }

    $threshold = (strftime('%s') - $frequency)

    # If the file is older than the threshold, update it
    if $::apt_update_last_success < $threshold {
        notice('Composer needs an update')
        exec { 'composer-selfupdate':
            command     => "${target_dir}/${composer_file} selfupdate",
            tries       => 3,
            timeout     => 1,
            environment => "COMPOSER_HOME=$::composer::params::composer_home",
        }

        Package[$php_package] -> File<| title=="${target_dir}/${composer_file}" |> -> Exec['composer-selfupdate']
    }
}
