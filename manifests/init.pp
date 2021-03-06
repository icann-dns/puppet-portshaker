# == Class: portshaker
#
class portshaker (
  String               $package                    = 'portshaker',
  Stdlib::Absolutepath $mirror_base_dir            = '/var/cache/portshaker',
  Array[String]        $ports_trees                = ['default'],
  Stdlib::Absolutepath $default_ports_tree         = '/usr/ports',
  String               $default_merge_from         = 'freebsd',
  String               $default_poudriere_tree     = 'default',
  Stdlib::Absolutepath $poudriere_ports_mountpoint = '/usr/local/poudriere/ports',
  String               $default_git_branch         = 'master',
  Boolean              $use_zfs                    = false,
  Boolean              $use_poudriere              = false,
  Stdlib::Absolutepath $portshaker_conf_file       = '/usr/local/etc/portshaker.conf',
  Boolean              $add_cron                   = true,
  Optional[Hash]       $git_clone_uri         = undef,
) {

  ensure_packages([$package])
  file{$portshaker_conf_file:
    ensure  => file,
    content => template('portshaker/usr/local/etc/portshaker.conf.erb'),
    require => Package[$package],
  }
  file{'/usr/local/etc/portshaker.d/freebsd':
    ensure  => file,
    mode    => '0555',
    source  => 'puppet:///modules/portshaker/usr/local/etc/portshaker.d/freebsd',
    require => Package[$package],
  }
  if ! empty($git_clone_uri) {
    ensure_packages(['git'])
    $git_clone_uri.each |$name, $config| {
      file{"/usr/local/etc/portshaker.d/${name}":
        ensure  => file,
        mode    => '0555',
        content => template('portshaker/usr/local/etc/portshaker.d/gitrepo.erb'),
        require => Package[$package],
      }
    }
  }
  if $add_cron {
    cron{'portshaker update':
      command => 'OUT=$(/usr/local/bin/portshaker -UM) || echo ${OUT}',
      hour    => 0,
      minute  => fqdn_rand(59),
    }
  }
}
