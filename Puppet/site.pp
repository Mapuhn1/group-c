# site.pp--- refactored with common class
node default {
# Applied to any node not matched by a specific node block below
include common
}

# Node classification: apply this block only to db-c
node 'db-c.oe2.org.nz' {
# Ensure vim is always installed on the db server
  include motd
  include mariadb
  include common
  package { 'vim':
     ensure => installed,
  }
  include nrpe
}

node 'app-c.oe2.org.nz' {
  include common
  include nrpe
}

node 'backup-c.oe2.org.nz' {
  include common
  include nrpe
}

# mgmt-c should also be a Puppet agent
node 'mgmt-c.oe2.org.nz' {
  include common
  include nagios
  include nagios_slack
}
