# modules/common/manifests/init.pp
# Classes applied to every managed node in the environment.
class common {
include sudo
include motd
}