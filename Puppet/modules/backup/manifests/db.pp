class backup::db {

  # --- db-c backup script ---
  file { '/usr/local/bin/backup-db-c.sh':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('backup/backup-db-c.sh.erb'),
    require => Class['backup::common'],
  }

  # --- Cron job: runs 4× daily at 0,6,12,18 ---
  cron { 'backup-db-c':
    ensure  => present,
    command => '/usr/local/bin/backup-db-c.sh',
    user    => 'root',
    hour    => [0, 6, 12, 18],
    minute  => $backup::cron_minute_offset,
    require => File['/usr/local/bin/backup-db-c.sh'],
  }

}
