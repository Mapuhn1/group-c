# modules/nagios/manifests/config.pp
# Manages Nagios configuration files and defines monitored hosts.
# Ordering is handled by init.pp-- nocross-class require needed here.
class nagios::config{
#--- Resource 1: Main Nagios configuration file--
# Source is the default nagios.cfg copied into the module's files/ directory.
# Mirrored path: files/etc/nagios4/nagios.cfg-> /etc/nagios4/nagios.cfg
file { '/etc/nagios4/nagios.cfg':
ensure => file,
owner => 'root',
group => 'root',
mode => '0644',
source => 'puppet:///modules/nagios/etc/nagios4/nagios.cfg',
require => Package['nagios4'],
}
#--- Resource 2: Web interface authentication file--
# Created with htpasswd and placed in the module's files/ directory.
# Contains bcrypt-hashed passwordsforthe nagiosadminuser.
file { '/etc/nagios4/htpasswd.users':
ensure => file,
owner => 'www-data',
group => 'www-data',
mode => '0640',
source => 'puppet:///modules/nagios/etc/nagios4/htpasswd.users',
require => Package['nagios4'],
}
#--- Resource 3: Ensure nagios user isin puppet group--
# This allows nagios to read config files written byPuppet
user { 'nagios':
ensure => present,
groups => 'puppet',
membership => 'minimum',
require => Package['nagios4'],
notify => Service['nagios4'],
}
#--- Resource 4: conf.d directory--
# Nagios loads all .cfg files from thisdirectory atstartup.
# Puppet writes nagios_host and nagios_serviceresources intothisdirectory.
# Group must be 'puppet' so thePuppetagentcan write resourcefileshere.
file { '/etc/nagios4/conf.d':
ensure => directory,
owner => 'root',
group => 'puppet',
mode => '0775',
}
#--- Resource : Nagios host definition for db-x--
# This Puppet-native resource type (provided by puppetlabs-nagios_core)
# writes a Nagios host definition into ppt_hosts.cfg inside conf.d/.
# Nagios reads this file at startup toknowwhichhosts to monitor.
nagios_host { 'db-x.oe2.org.nz':
target => '/etc/nagios4/conf.d/ppt_hosts.cfg',
alias => 'db',
check_period => '24x7',
max_check_attempts => 3,
check_command =>'check-host-alive',
notification_interval => 30,
notification_period => '24x7',
notification_options =>'d,u,r',
require => File['/etc/nagios4/conf.d'],
notify => Exec['fix_confd_permissions'],
}
}