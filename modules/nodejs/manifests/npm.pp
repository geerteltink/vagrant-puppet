define nodejs::npm (
    $module      = $title,
    $ensure      = present,
    $options     = '-g',
    $modules_dir = '/usr/lib'
) {

    $validate = "${modules_dir}/node_modules/${module}:${module}"

    if $ensure == present {
        exec { "npm-install-${name}":
            command     => "npm install ${options} ${module}",
            unless      => "npm list -p -l | grep '${validate}'",
            cwd         => $modules_dir
        }

        # First (un)install npm, then install nodejs (might include npm) and
        # the npm module last.
        Package<| title == 'npm' |> -> Package['nodejs'] -> Exec["npm-install-${name}"]
    } else {
        exec { "npm-remove-${name}":
            command     => "npm remove ${module}",
            onlyif      => "npm list -p -l | grep '${validate}'",
            cwd         => $modules_dir
        }

        # First remove the module, then npm and nodejs
        Exec["npm-remove-${name}"] -> Package<| title == 'npm' |> -> Package['nodejs']
    }
}
