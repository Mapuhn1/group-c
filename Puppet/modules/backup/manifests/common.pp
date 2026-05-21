# /etc/puppetlabs/code/modules/backup/manifests/common.pp
class backup::common {

  # --- Backup script directory ---
  file { '/usr/local/lib/backup':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  # --- Shared rsync wrapper ---
  file { '/usr/local/lib/backup/rsync-to-backup.sh':
    ensure  => file,
    source  => 'puppet:///modules/backup/rsync-to-backup.sh',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => File['/usr/local/lib/backup'],
  }

  # --- Exclude list ---
  file { '/usr/local/lib/backup/exclude.list':
    ensure  => file,
    source  => 'puppet:///modules/backup/exclude.list',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => File['/usr/local/lib/backup'],
  }

  # --- SSH directory (mode only, no keys shipped through Puppet) ---
  file { '/root/.ssh':
    ensure => directory,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

}
