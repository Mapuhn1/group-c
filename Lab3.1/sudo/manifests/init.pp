# modules/sudo/manifests/init.pp
# Manages the sudo package and its configuration file.
class sudo {
# Resource 1: ensure the sudo package is installed
package { 'sudo':
ensure => present,
}
# Resource 2: manage the sudoers configuration file
file { '/etc/sudoers':
owner
=> 'root',
group
=> 'root',
mode
=> '0440',
source => 'puppet:///modules/sudo/etc/sudoers',
require => Package['sudo'],
validate_cmd => '/usr/sbin/visudo-cf %',
}
}