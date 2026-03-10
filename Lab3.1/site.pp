# site.pp
node 'db-x.oe2.org.nz' {
include sudo
include motd
}
node 'app-x.oe2.org.nz' {
include motd
}
node 'backup-x.oe2.org.nz' {
include motd
}
# mgmt-x should also be a Puppet agent
node 'mgmt-x.oe2.org.nz' {
include motd
}