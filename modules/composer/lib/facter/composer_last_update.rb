require 'facter'

# Get the last composer self-update time.
Facter.add('composer_last_update') do
  setcode do
    if File.exists?('/usr/local/bin/composer')
      #get epoch time
      lastsuccess = File.mtime('/usr/local/bin/composer').to_i
      lastsuccess
    else
      lastsuccess = -1
      lastsuccess
    end
  end
end
