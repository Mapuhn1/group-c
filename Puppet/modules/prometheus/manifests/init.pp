class prometheus (
  Boolean $install_server        = false,
  Boolean $install_node_exporter = false,
) {

  if $install_server {
    include prometheus::server
  }

  if $install_node_exporter {
    include prometheus::node_exporter
  }

  contain prometheus::install
  contain prometheus::config
  contain prometheus::service

# Enforce application order
  Class['prometheus::install']
  -> Class['prometheus::config']
  ~> Class['prometheus::service']

}
