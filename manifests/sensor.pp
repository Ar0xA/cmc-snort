#Sensor class for deployment

class snort::sensor (
  $gbl_home_net = undef,
  $external_net = '!$HOME_NET', #note, cannot be !any 
  $dns_servers = '$HOME_NET',
  $snort_perfprofile = false,
  $stream_memcap = '8388608',
  $stream_prune_log_max = '1048576',
  $stream_max_queued_segs = '2621',
  $stream_max_queued_bytes = '1048576',
  $perfmonitor_pktcnt = '10000',
  $dcerpc2_memcap = '102400',
  $enable = true,
  $ensure = running,
  $norules = false
){

  #we shouldnt really use "any" for HOME_NET but its technically allowable
  #Still we hack this to add all local ip's and their subnets to 
  #the HOME_NET if not defined at all
  if $gbl_home_net == undef {
    $home_net = snort_ip_cidr()
  } else {
    #passed from global
    $home_net = $gbl_home_net
  }

  package {
    'snort':
      ensure => 'installed',
  }
  package {
    'daq':
      ensure  => 'installed',
      require => Package['snort']
  }

  #upload and compile custom selinux module for snort
  selinux::module {'snort-sss':
        source => 'puppet:///modules/snort/snort-sss.te',
  }

  if $norules == true {
    file {
      '/etc/snort/rules':
        ensure  => directory,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        require => Package['snort']
    }
  }
  else {
    file {
      '/etc/snort/rules':
        ensure  => directory,
        source  => 'puppet:///modules/snort/rules/rules',
        purge   => true,
        ignore  => '.svn',
        recurse => true,
        force   => true,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['snortd'],
        require => Package['snort']
    }
    file {
      '/etc/snort/ipreputation':
        ensure  => directory,
        source  => 'puppet:///modules/snort/rules/ipreputation',
        purge   => true,
        ignore  => '.svn',
        recurse => true,
        force   => true,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['snortd'],
        require => Package['snort']
    }
    file {
      '/etc/snort/community_rules':
        ensure  => directory,
        source  => 'puppet:///modules/snort/rules/community-rules',
        purge   => true,
        ignore  => '.svn',
        recurse => true,
        force   => true,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['snortd'],
        require => Package['snort']
    }
    
    file {
      '/etc/snort/so_rules':
        ensure  => directory,
        source  => 'puppet:///modules/snort/rules/so_rules',
        purge   => true,
        ignore  => '.svn',
        recurse => true,
        force   => true,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['snortd'],
        require => Package['snort']
    }
    file {
      '/etc/snort/preproc_rules':
        ensure  => directory,
        source  => 'puppet:///modules/snort/rules/preproc_rules',
        purge   => true,
        ignore  => '.svn',
        recurse => true,
        force   => true,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['snortd'],
        require => Package['snort']
    }

  }

  file {
    '/etc/snort/rules/local.rules':
      ensure  => present,
      source  => [ "puppet:///modules/snort/local/local.rules-${::fqdn}",
                  'puppet:///modules/snort/local/local.rules' ],
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      force   => true,
      notify  => Service['snortd'],
      require => Package['snort']
  }
  
  file {
    '/etc/snort/snort.conf':
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      alias   => 'snortconf',
      content => template( 'snort/snort.conf.erb'),
      notify  => Service['snortd'],
      require => Package['snort']
  }
  
  file {
    '/etc/sysconfig/snort':
      source  => [ "puppet:///modules/snort/sysconfig/snort-${::fqdn}",
                  'puppet:///modules/snort/sysconfig/snort' ],
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['snortd'],
      require => Package['snort']
  }
  file {
    '/etc/cron.d/snort-clean' :
      source => 'puppet:///modules/snort/snortcleanup.cron',
      mode   => '0440',
      owner  => 'root',
      group  => 'root'
  }
  file {
    '/usr/local/sbin/snortcleanup.sh' :
      source => 'puppet:///modules/snort/snortcleanup.sh',
      mode   => '0550',
      owner  => 'root',
      group  => 'root'
  }


  service {
    'snortd':
      ensure     => $ensure,
      enable     => $enable,
      hasstatus  => true,
      hasrestart => true,
      require    => Package['snort'];
  }
}

