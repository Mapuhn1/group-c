class prometheus::config {
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
  file { '/usr/local/bin/prometheus/rule1.yml':
    ensure  => file,
    owner   => 'prometheus',
    group   => 'prometheus',
    mode    => '0644',
    content => template('prometheus/rule1.yml.erb'),
    notify  => Service['prometheus'],
  }

  # Deploy rule file 2
  file { '/usr/local/bin/prometheus/rule2.yml':
    ensure  => file,
    owner   => 'prometheus',
    group   => 'prometheus',
    mode    => '0644',
    content => template('prometheus/rule2.yml.erb'),
    notify  => Service['prometheus'],
  }

}
