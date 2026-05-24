class backup::app {

  # --- app-c backup script ---
  file { '/usr/local/bin/backup-app-c.sh':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('backup/backup-app-c.sh.erb'),
    require => Class['backup::common'],
  }

  # --- Cron job: runs 4× daily at 0,6,12,18 ---
  cron { 'backup-app-c':
    ensure  => present,
    command => '/usr/local/bin/backup-app-c.sh',
    user    => 'root',
    hour    => [0, 6, 12, 18],
    minute  => $backup::cron_minute_offset,
    require => File['/usr/local/bin/backup-app-c.sh'],
  }

}
