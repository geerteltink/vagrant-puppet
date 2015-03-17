# Create a new run stage to ensure certain modules are included first
stage { 'pre':
  before => Stage['main']
}

# Set defaults for file ownership/permissions
File {
  owner => 'root',
  group => 'root',
  mode  => '0644'
}

debug("Starting devbox with hostname: ${::hostname}")

# Add the baseconfig module to the new 'pre' run stage
class { 'core::apt-update':
  stage => 'pre'
}

class { 'core::git': }

class { 'mysql': }

class { 'php': }

class { 'apache': }

class { 'phpmyadmin': }

class { 'phantomjs': }

class { 'nodejs': }
