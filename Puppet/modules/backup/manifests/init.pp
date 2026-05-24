# /etc/puppetlabs/code/modules/backup/manifests/init.pp
class backup (
  Integer $cron_minute_offset = 0,
) {
  include backup::common

  case $facts['networking']['hostname'] {
    'mgmt-c':     { include backup::mgmt }
    'db-c':       { include backup::db }
    'app-c':      { include backup::app }
    'backup-c':   { include backup::monitoring }
  }
}
