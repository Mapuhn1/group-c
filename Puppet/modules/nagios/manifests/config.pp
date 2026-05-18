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
group => 'nagios',
mode => '0644',
source => 'puppet:///modules/nagios/etc/nagios4/nagios.cfg',
require => Package['nagios4'],
}
#--- Resource 2: Web interface authentication file--
# Created with htpasswd and placed in the module's files/ directory.
# Contains bcrypt-hashed passwordsforthe nagiosadminuser.
file { '/etc/nagios4/htpasswd.users':
ensure => file,
owner => 'root',
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

file { '/etc/nagios4/conf.d/ppt_commands.cfg':
  ensure  => file,
  owner   => 'root',
  group   => 'nagios',
  mode    => '0640',
}

file { '/usr/lib/nagios/plugins':
    ensure => directory,
}

file { '/usr/lib/nagios/plugins/check_mem.pl':
    ensure  => file,
    source  => 'puppet:///modules/nagios/check_mem.pl',
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0755',
    require => File['/usr/lib/nagios/plugins'],
}

#--- Resource : Nagios host definition for db-x--
# This Puppet-native resource type (provided by puppetlabs-nagios_core)
# writes a Nagios host definition into ppt_hosts.cfg inside conf.d/.
# Nagios reads this file at startup toknowwhichhosts to monitor.
#nagios_host { 'db-c.oe2.org.nz':
#target => '/etc/nagios4/conf.d/ppt_hosts.cfg',
#alias => 'db-c',
#check_period => '24x7',
#max_check_attempts => 3,
#check_command =>'check-host-alive',
#notification_interval => 30,
#notification_period => '24x7',
#notification_options =>'d,u,r',
#require => File['/etc/nagios4/conf.d'],
#notify => Exec['fix_confd_permissions'],
#}


nagios::monitored_host { 'db-c.oe2.org.nz': host_alias => 'db-c'}


# --- SSH service check for db-x ---
# Verifies that TCP port 22 is open and accepting connections.
# This catches cases where the host responds to ping but SSH has crashed.
#nagios_service { 'SSH on db-c':
#host_name => 'db-c.oe2.org.nz',
#service_description => 'SSH',
#target => '/etc/nagios4/conf.d/ppt_services.cfg',
#check_command => 'check_ssh',
#check_period => '24x7',
#max_check_attempts => 3,
#check_interval => 2,
#notification_interval => 30,
#notification_period => '24x7',
#notification_options => 'w,c,r',
#}

# --- Service: SSH check on all SSH servers ---
# Applies to every member of my-ssh-servers via hostgroup_name.
# When a new host is added to the group, this check follows automatically.

nagios_service { 'ssh-check':
  service_description   => 'SSH',
  hostgroup_name        => 'my-ssh-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_ssh',
  max_check_attempts    => 3,
  normal_check_interval        => 5,
  retry_check_interval        => 1,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup',
}

# --- Service: MariaDB check on the database server ---
# Uses check_mysql with credentials stored in resource.cfg ($USER10$/$USER11$)
# The ! delimiter passes each argument to the command template
nagios_service { 'mariadb-check':
  service_description => 'MariaDB',
  hostgroup_name => 'my-db-servers',
  target => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command => 'check_mysql_cmdlinecred!nagios!NagiosMonitor1',
  max_check_attempts => 3,
  normal_check_interval => 5,
  retry_check_interval => 1,
  check_period => '24x7',
  notification_interval => 30,
  notification_period => '24x7',
  notification_options => 'w,u,c,r',
  contact_groups => 'slackgroup',
}

# --- Service: HTTPS check on the management server ---
# Checks that the Nagios web interface is reachable and returns HTTP 200.
# -S enables SSL (HTTPS), --sni sends the correct hostname for TLS.
nagios_service { 'https-nagios':
  service_description => 'HTTPS Nagios Interface',
  hostgroup_name => 'my-mgmt-servers',
  target => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command => 'check_http! -S 1.2+ --sni -u /nagios4/ -e "HTTP/1.1 401"',
  max_check_attempts => 3,
  check_interval => 5,
  retry_interval => 1,
  check_period => '24x7',
  notification_interval => 30,
  notification_period => '24x7',
  notification_options => 'w,u,c,r',
  contact_groups => 'slackgroup',
}

# --- mgmt-x as a monitored host ---
# Monitoring the management server itself.
#nagios_host { 'mgmt-c.oe2.org.nz':
#target => '/etc/nagios4/conf.d/ppt_hosts.cfg',
#alias => 'mgmt',
#check_period => '24x7',
#max_check_attempts => 3,
#check_command => 'check-host-alive',
#notification_interval => 30,
#notification_period => '24x7',
#notification_options => 'd,u,r',
#}

nagios::monitored_host { 'mgmt-c.oe2.org.nz': host_alias => 'mgmt-c'}


# Set Apache ServerName to the group domain.
# certbot --apache reads this to know which domain to certify.
# Replace group-x with your group letter.
file_line { 'apache_servername':
path => '/etc/apache2/apache2.conf',
line => 'ServerName group-c.op-bit.nz',
match => '^ServerName',
}



# --- app-c as a monitored host ---
# Monitoring the management server itself.
#nagios_host { 'app-c.oe2.org.nz':
#target => '/etc/nagios4/conf.d/ppt_hosts.cfg',
#alias => 'app',
#check_period => '24x7',
#max_check_attempts => 3,
#check_command => 'check-host-alive',
#notification_interval => 30,
#notification_period => '24x7',
#notification_options => 'd,u,r',
#}

nagios::monitored_host { 'app-c.oe2.org.nz': host_alias => 'app-c'}



# --- backup-c as a monitored host ---
# Monitoring the management server itself.
#nagios_host { 'backup-c.oe2.org.nz':
#target => '/etc/nagios4/conf.d/ppt_hosts.cfg',
#alias => 'backup',
#check_period => '24x7',
#max_check_attempts => 3,
#check_command => 'check-host-alive',
#notification_interval => 30,
#notification_period => '24x7',
#notification_options => 'd,u,r',
#}

nagios::monitored_host { 'backup-c.oe2.org.nz':  host_alias => 'backup-c'}

# -- Host groups --
# Group all hosts that run SSH (db, app, backup, and mgmt)
# members must exactly match the nagios_host resource titles
nagios_hostgroup { 'my-ssh-servers':
target => '/etc/nagios4/conf.d/ppt_hostgroups.cfg',
alias => 'All SSH Servers',
members => 'db-c.oe2.org.nz,app-c.oe2.org.nz,backup-c.oe2.org.nz,mgmt-c.oe2.org.nz'
}

# Group containing only the database server
nagios_hostgroup { 'my-db-servers':
target => '/etc/nagios4/conf.d/ppt_hostgroups.cfg',
alias => 'Database Servers',
members => 'db-c.oe2.org.nz',
}
# Group containing the management server for mgmt-specific checks
nagios_hostgroup { 'my-mgmt-servers':
target => '/etc/nagios4/conf.d/ppt_hostgroups.cfg',
alias => 'Management Servers',
members => 'mgmt-c.oe2.org.nz',
}
# Group containing the web servers
nagios_hostgroup { 'my-web-servers':
target => '/etc/nagios4/conf.d/ppt_hostgroups.cfg',
alias => 'Web Servers',
members => 'mgmt-c.oe2.org.nz,app-c.oe2.org.nz',
}


# --- Host group: all nodes monitored via NRPE ---
# Includes the three agent nodes; mgmt-c is excluded
# (mgmt-c is the monitoring server, not a monitored node)

nagios_hostgroup { 'my-nrpe-servers':
  target => '/etc/nagios4/conf.d/ppt_hostgroups.cfg',
  alias  => 'NRPE Monitored Servers',
  members => 'db-c.oe2.org.nz,app-c.oe2.org.nz,backup-c.oe2.org.nz',
}

# --- MGMT Services ---

# MGMT Memory Check
nagios_command { 'check_mgmt_mem':
  command_line => '/usr/lib/nagios/plugins/check_mem.pl -f -w 5 -c 1',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios_service { 'mgmt-mem':
  service_description   => 'Memory Usage',
  hostgroup_name        => 'my-mgmt-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_mgmt_mem',
  max_check_attempts    => 3,
  normal_check_interval => 10,
  retry_check_interval  => 2,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup',
}

# MGMT CPU Load Check
nagios_command { 'check_mgmt_load':
  command_line => '/usr/lib/nagios/plugins/check_load -w 5,4,3 -c 10,8,6',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios_service { 'mgmt-load':
  service_description   => 'CPU Load',
  hostgroup_name        => 'my-mgmt-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_mgmt_load',
  max_check_attempts    => 3,
  normal_check_interval => 10,
  retry_check_interval  => 2,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup',
}

#MGMT Disk Space check
nagios_command { 'check_mgmt_disk':
  command_line => '/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios_service { 'mgmt-disk':
  service_description   => 'Disk Space',
  hostgroup_name        => 'my-mgmt-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_mgmt_disk',
  max_check_attempts    => 3,
  normal_check_interval => 10,
  retry_check_interval  => 2,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup',
}

#MGMT Logged-in users check
nagios_command { 'check_mgmt_users':
  command_line => '/usr/lib/nagios/plugins/check_users -w 1 -c 10',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios::monitored_service { 'mgmt-users':
  service_description => 'Logged-In Users',
  hostgroup_name      => 'my-mgmt-servers',
  check_command       => 'check_mgmt_users',
}

#MGMT Process-count check
nagios_command { 'check_mgmt_procs':
  command_line => '/usr/lib/nagios/plugins/check_procs -w 250 -c 400',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios::monitored_service { 'mgmt-procs':
  service_description => 'Process Count',
  hostgroup_name      => 'my-mgmt-servers',
  check_command       => 'check_mgmt_procs',
}

#MGMT Zombie Processes check
nagios_command { 'check_mgmt_zombie_procs':
  command_line => '/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios::monitored_service { 'mgmt-zombie-procs':
  service_description => 'Zombie Processes',
  hostgroup_name      => 'my-mgmt-servers',
  check_command       => 'check_mgmt_procs',
}

#MGMT DNS check
nagios_command { 'check_mgmt_dns':
  command_line => '/usr/lib/nagios/plugins/check_dns -H google.com -w 2 -c 5',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios::monitored_service { 'mgmt-dns':
  service_description => 'DNS Lookup',
  hostgroup_name      => 'my-mgmt-servers',
  check_command       => 'check_mgmt_dns',
}

#MGMT Swap check
nagios_command { 'check_mgmt_swap':
  command_line => '/usr/lib/nagios/plugins/check_swap -w 20% -c 10%',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios::monitored_service { 'mgmt-swap':
  service_description => 'Swap Usage',
  hostgroup_name      => 'my-mgmt-servers',
  check_command       => 'check_mgmt_swap',
}



# --- Web Services ---
# HTTP Check
nagios_command { 'web_http':
  command_line => '/usr/lib/nagios/plugins/check_http -H localhost -I 127.0.0.1 -u / -w 5 -c 10',
  target       => '/etc/nagios4/conf.d/ppt_commands.cfg',
}

nagios::monitored_service { 'mgmt-http':
  service_description => 'HTTP',
  hostgroup_name      => 'my-web-servers',
  check_command       => 'web_http',
}



# --- NRPE Services ---

# --- NRPE service: disk space check ---
# Uses check_nrpe with the argument matching the command[] name in nrpe.cfg
# The ! delimiter passes the command name to the check_nrpe plugin template

nagios_service { 'nrpe-disk':
  service_description   => 'Disk Space',
  hostgroup_name        => 'my-nrpe-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_nrpe!check_disk',
  max_check_attempts    => 3,
  normal_check_interval => 10,
  retry_check_interval  => 2,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup'
}

# --- NRPE service: Memory check ---
nagios_service { 'nrpe-mem':
  service_description   => 'Memory Usage',
  hostgroup_name        => 'my-nrpe-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_nrpe!check_mem',
  max_check_attempts    => 3,
  normal_check_interval => 10,
  retry_check_interval  => 2,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup',
}

# --- NRPE service: CPU load check ---

nagios_service { 'nrpe-load':
  service_description   => 'CPU Load',
  hostgroup_name        => 'my-nrpe-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_nrpe!check_load',
  max_check_attempts    => 3,
  normal_check_interval => 5,
  retry_check_interval  => 1,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup'
}

# --- NRPE service: logged-in users check ---

nagios_service { 'nrpe-users':
  service_description   => 'Logged-In Users',
  hostgroup_name        => 'my-nrpe-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_nrpe!check_users',
  max_check_attempts    => 3,
  normal_check_interval => 10,
  retry_check_interval  => 2,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup'
}

# --- NRPE service: process count check ---

nagios_service { 'nrpe-procs':
  service_description   => 'Process Count',
  hostgroup_name        => 'my-nrpe-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_nrpe!check_procs',
  max_check_attempts    => 3,
  normal_check_interval => 5,
  retry_check_interval  => 1,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup'
}

# -- NRPE service: zombie process check --

nagios_service { 'nrpe-zombies':
  service_description   => 'Zombie Processes',
  hostgroup_name        => 'my-nrpe-servers',
  target                => '/etc/nagios4/conf.d/ppt_services.cfg',
  check_command         => 'check_nrpe!check_zombie_procs',
  max_check_attempts    => 3,
  normal_check_interval => 5,
  retry_check_interval  => 1,
  check_period          => '24x7',
  notification_interval => 30,
  notification_period   => '24x7',
  notification_options  => 'w,u,c,r',
  contact_groups        => 'slackgroup',
}

nagios::monitored_service { 'nrpe-dns':
  service_description => 'DNS Lookup',
  hostgroup_name      => 'my-nrpe-servers',
  check_command       => 'check_nrpe!check_dns',
}


nagios::monitored_service { 'nrpe-swap':
  service_description => 'Swap Usage',
  hostgroup_name      => 'my-nrpe-servers',
  check_command       => 'check_nrpe!check_swap',
}


# --- Slack contact ---
# This contact represents the Slack channel as a notification recipient.
# email is required by Nagios even when not using email notifications.
# root@localhost is a harmless placeholder — no email will actually be sent.

nagios_contact { 'slack':
  target                       => '/etc/nagios4/conf.d/ppt_contacts.cfg',
  alias                        => 'Slack Channel',
  service_notification_period  => '24x7',
  host_notification_period     => '24x7',
  service_notification_options => 'w,u,c,r',
  host_notification_options    => 'd,r',
  service_notification_commands => 'notify-service-by-slack',
  host_notification_commands    => 'notify-host-by-slack',
  email                        => 'root@localhost',
  owner                        => 'root',
  group                        => 'nagios',
  mode                         => '0644',
}

# --- Slack contact group ---
# Groups the Slack contact so services can reference 'slackgroup'.
# A contact group can contain multiple contacts (e.g., slack AND email).

nagios_contactgroup { 'slackgroup':
  target => '/etc/nagios4/conf.d/ppt_contacts.cfg',
  alias  => 'Slack Notification Channel',
  members => 'slack',
  owner   => 'root',
  group   => 'nagios',
  mode    => '0644',
}

}
