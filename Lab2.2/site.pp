# Node classification: apply this block only to db-c
node 'db-c.oe2.org.nz' {
# Ensure vim is always installed on the db server
package { 'vim':
ensure => installed,
}
}