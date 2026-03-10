# modules/motd/manifests/init.pp
# Manages /etc/motd using a per-node EPP template.
class motd {
file { '/etc/motd':
ensure => file,
owner
=> 'root',
group
=> 'root',
mode
=> '0644',
content => epp('motd/motd.epp', {
'hostname' => $facts['networking']['hostname'],
'ip'
=> $facts['networking']['ip'],
'os'
=> $facts['os']['distro']['description'],
}),
}
}