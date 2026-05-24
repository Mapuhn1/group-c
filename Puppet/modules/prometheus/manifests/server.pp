class prometheus::server {

  package { 'prometheus':
    ensure => installed,
  }

  service { 'prometheus':
    ensure => running,
    enable => true,
  }

}
