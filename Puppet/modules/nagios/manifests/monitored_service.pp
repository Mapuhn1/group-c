define nagios::monitored_service (
  String  $service_description     = $title,
  String  $hostgroup_name,
  String  $check_command,
  Integer $max_check_attempts      = 3,
  Integer $normal_check_interval   = 5,
  Integer $retry_check_interval    = 1,
  String  $check_period            = '24x7',
  Integer $notification_interval   = 30,
  String  $notification_period     = '24x7',
  String  $notification_options    = 'w,u,c,r',
  String  $contact_groups          = 'slackgroup',
) {

  nagios_service { $title:
    target                  => '/etc/nagios4/conf.d/ppt_services.cfg',
    service_description     => $service_description,
    hostgroup_name          => $hostgroup_name,
    check_command           => $check_command,
    max_check_attempts      => $max_check_attempts,
    normal_check_interval   => $normal_check_interval,
    retry_check_interval    => $retry_check_interval,
    check_period            => $check_period,
    notification_interval   => $notification_interval,
    notification_period     => $notification_period,
    notification_options    => $notification_options,
    contact_groups          => $contact_groups,
  }
}
