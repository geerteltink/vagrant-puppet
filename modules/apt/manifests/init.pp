class apt (
    $frequency = $::apt::params::update_frequency
) inherits apt::params {

    include apt::update

    validate_integer($frequency)

    $threshold = (strftime('%s') - $frequency)

    # If the sources list is older than the threshold, update it
    if $::apt_update_last_success < $threshold {
        notice('The package lists need an update')
        Exec <| title=='apt-update' |> {
            refreshonly => false
        }
    }
}
