#--- SSH service check for db-c--
# Verifies that TCP port 22 is open and accepting connections.
# This catches cases where the host responds to ping but SSH has crashed.
nagios_service { 'SSH on db-c':
host_name => 'db-c.oe2.org.nz',
service_description => 'SSH',
target => '/etc/nagios4/conf.d/ppt_services.cfg',
check_command => 'check_ssh',
check_period => '24x7',
max_check_attempts => 3,
notification_interval => 30,
notification_period => '24x7',
notification_options =>'w,c,r',
}
#--- mgmt-c as a monitored host--
# Monitoring the management server itself.
nagios_host { 'mgmt-c.oe2.org.nz':
target => '/etc/nagios4/conf.d/ppt_hosts.cfg',
alias => 'mgmt',
check_period => '24x7',
max_check_attempts => 3,
check_command =>'check-host-alive',
notification_interval => 30,
notification_period => '24x7',
notification_options => 'd,u,r',
}