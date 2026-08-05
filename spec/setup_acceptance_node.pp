if fact('os.family') == 'redhat' {
  file { '/var/run/chrony':
    ensure => directory,
  }
}
if fact('os.family') == 'Archlinux' {
  file { '/etc/sysconfig':
    ensure => directory,
  }
}


# Ubuntu and Debian ships chrony.service with
# ConditionVirtualization=|!container / |wsl, so systemd refuses to ever
# start the unit inside a container-based acceptance node -- unrelated to
# anything Puppet manages. This is a deliberate distribution decision,
# not a module bug, so the workaround is confined to the test harness
# rather than shipped in manifests/. See
# https://github.com/voxpupuli/puppet-chrony/pull/254#issuecomment-5308411879

if fact('os.family') == 'Debian' {
  file { '/etc/systemd/system/chrony.service.d':
    ensure => directory,
  }

  file { '/etc/systemd/system/chrony.service.d/override.conf':
    ensure  => file,
    content => "[Unit]\nConditionVirtualization=\n",
    notify  => Exec['chrony-systemd-daemon-reload'],
  }

  exec { 'chrony-systemd-daemon-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => ['/usr/bin', '/bin'],
  }
}
