# site.pp--- refactored with common class
node default {
# Applied to any node not matched by a specific node block below
include common
}

# Node classification: apply this block only to db-c
node 'db-c.oe2.org.nz' {
# Ensure vim is always installed on the db server
  include common
  package { 'vim':
     ensure => installed,
  }

}

node 'app-c.oe2.org.nz' {
  include common
}

node 'backup-c.oe2.org.nz' {
  include common
}

# mgmt-x should also be a Puppet agent
node 'mgmt-c.oe2.org.nz' {
  include common
}

