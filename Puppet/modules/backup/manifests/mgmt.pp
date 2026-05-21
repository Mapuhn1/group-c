class backup::mgmt {

  # --- mgmt-c backup script ---
  file { '/usr/local/bin/backup-mgmt-c.sh':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('backup/backup-mgmt-c.sh.erb'),
    require => Class['backup::common'],
  }

  # --- Cron job: runs 4× daily at 0,6,12,18 ---
  cron { 'backup-mgmt-c':
    ensure  => present,
    command => '/usr/local/bin/backup-mgmt-c.sh',
    user    => 'root',
    hour    => [0, 6, 12, 18],
    minute  => $backup::cron_minute_offset,
    require => File['/usr/local/bin/backup-mgmt-c.sh'],
  }
  
}
