#
#
class portshaker::params {
  $package                    = 'portshaker'
  $mirror_base_dir            = '/var/cache/portshaker'
  $ports_trees                = ['default']
  $default_ports_tree         = '/usr/ports'
  $default_merge_from         = 'freebsd'
  $default_poudriere_tree     = 'default'
  $poudriere_ports_mountpoint = '/usr/local/poudriere/ports'
  $git_clone_uri              = undef
  $git_branch                 = 'master'
  $use_zfs                    = false
  $use_poudriere              = false
  $portshaker_conf_file       = '/usr/local/etc/portshaker.conf'
  $portshaker_conf_tmpl       = 'portshaker/usr/local/etc/portshaker.conf.erb'
  $add_cron                   = true
}
