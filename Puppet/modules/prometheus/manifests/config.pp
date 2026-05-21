class prometheus::config {

  # Ensure the Prometheus config directory exists
  file { '/usr/local/bin/prometheus':
    ensure => directory,
    owner  => 'prometheus',
    group  => 'prometheus',
    mode   => '0755',
  }

  # Ensure the data directory exists (PDF requirement)
  file { '/var/lib/prometheus/data':
    ensure => directory,
    owner  => 'prometheus',
    group  => 'prometheus',
    mode   => '0755',
  }

  # Deploy the main Prometheus configuration file
  file { '/usr/local/bin/prometheus/prometheus.yml':
    ensure  => file,
    owner   => 'prometheus',
    group   => 'prometheus',
    mode    => '0644',
    content => template('prometheus/prometheus.yml.erb'),
    notify  => Service['prometheus'],
  }

  # Deploy rule file 1
  file { '/usr/local/bin/prometheus/rules/rule1.yml':
    ensure  => file,
    owner   => 'prometheus',
    group   => 'prometheus',
    mode    => '0644',
    content => template('prometheus/rule1.yml.erb'),
    notify  => Service['prometheus'],
  }

  # Deploy rule file 2
  file { '/usr/local/bin/prometheus/rules/rule2.yml':
    ensure  => file,
    owner   => 'prometheus',
    group   => 'prometheus',
    mode    => '0644',
    content => template('prometheus/rule2.yml.erb'),
    notify  => Service['prometheus'],
  }

}
