# modules/nagios/manifests/init.pp
# Entry point for thenagios module.
# Nagios runs on mgmt-x ONLY--neverincludethisin the common class.
#comment
class nagios {
contain nagios::install
contain nagios::config
contain nagios::service
# Enforce application order
Class['nagios::install']-> Class['nagios::config']
~> Class['nagios::service']
}