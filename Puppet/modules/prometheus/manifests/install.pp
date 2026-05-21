class prometheus::install {

  package { ['wget', 'tar']:
    ensure => installed,
  }

  # Download Prometheus 2.53.4 (as per the PDF)
  exec { 'download_prometheus':
    command => 'wget https://github.com/prometheus/prometheus/releases/download/v2.53.4/prometheus-2.53.4.linux-amd64.tar.gz',
    cwd     => '/opt',
    creates => '/opt/prometheus-2.53.4.linux-amd64.tar.gz',
    path    => ['/usr/bin', '/bin'],
    require => Package['wget'],
  }

  # Extract the tarball
  exec { 'extract_prometheus':
    command => 'tar -xvf prometheus-2.53.4.linux-amd64.tar.gz',
    cwd     => '/opt',
    creates => '/opt/prometheus-2.53.4.linux-amd64/prometheus',
    path    => ['/usr/bin', '/bin'],
    require => Exec['download_prometheus'],
  }

  # Create the Prometheus installation directory
  file { '/usr/local/bin/prometheus':
    ensure => directory,
    owner  => 'prometheus',
    group  => 'prometheus',
    mode   => '0755',
  }

  # Copy the entire extracted directory contents (PDF requirement)
  exec { 'copy_prometheus_tree':
    command => 'cp -r /opt/prometheus-2.53.4.linux-amd64/* /usr/local/bin/prometheus/',
    creates => '/usr/local/bin/prometheus/prometheus',
    path    => ['/usr/bin', '/bin'],
    require => Exec['extract_prometheus'],
  }

  # Create the Prometheus user (no home, no shell)
  user { 'prometheus':
    ensure     => present,
    managehome => false,
    shell      => '/usr/sbin/nologin',
  }

  # Create the data directory (PDF requirement)
  file { '/var/lib/prometheus/data':
    ensure => directory,
    owner  => 'prometheus',
    group  => 'prometheus',
    mode   => '0755',
  }

  # Ensure ownership of the Prometheus binary tree
  exec { 'fix_prometheus_permissions':
    command => 'chown -R prometheus:prometheus /usr/local/bin/prometheus',
    path    => ['/usr/bin', '/bin'],
    require => [User['prometheus'], Exec['copy_prometheus_tree']],
  }

}
