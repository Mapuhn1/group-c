class owncloud_users::config {

  file { '/root/create_oc_users.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/owncloud_users/create_oc_users.sh',
  }

  file { '/root/user_credentials.csv':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('owncloud_users/user_list.csv.erb'),
  }

  exec { 'create_owncloud_users':
    command => '/root/create_oc_users.sh',
    path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    require => [
      File['/root/create_oc_users.sh'],
      File['/root/user_credentials.csv'],
    ],
    logoutput => true,
  }

}
