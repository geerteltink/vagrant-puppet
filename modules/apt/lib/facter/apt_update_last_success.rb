require 'facter'

# The last update time is derived from the file /var/cache/apt/pkgcache.bin.
# This is generated upon a successful apt-get update run natively in ubuntu.
# The apt module deploys this same functionality for other debian-ish OSes.
Facter.add('apt_update_last_success') do
  confine :osfamily => 'Debian'
  setcode do
    if File.exists?('/var/cache/apt/pkgcache.bin')
      #get epoch time
      lastsuccess = File.mtime('/var/cache/apt/pkgcache.bin').to_i
      lastsuccess
    else
      lastsuccess = -1
      lastsuccess
    end
  end
end
