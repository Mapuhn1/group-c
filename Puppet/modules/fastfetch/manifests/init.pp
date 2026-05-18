class fastfetch {
  file { '/usr/local/bin/fastfetch':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/fastfetch/fastfetch', 
  }

  
}
