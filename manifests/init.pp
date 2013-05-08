class ldap_auth(
  $uri,
  $base,
  $scope           = undef,
  $ldap_version    = undef,
  $package_version = 'installed',
  $packages        = $::ldap_auth::params::packages,
  $configure_nss   = $::ldap_auth::params::configure_nss,
  $configure_pam   = $::ldap_auth::params::configure_pam,
) inherits ldap_auth::params{

  validate_bool($configure_nss)
  validate_bool($configure_pam)

  package { $packages:
    ensure => $package_version,
  }

  # Do we want to configure NSS related ldap componenets?
  # $nss_server is only used when we have a system using nslcd
  if $configure_nss {
    $nss_ensure  = 'file'
    $nss_service = 'running'

    if $::ldap_auth::params::nslcd {
      $nss_content = template("ldap_auth/nslcd.conf.erb")
      $nss_notify  = Service['nslcd,sssd']
    } else {
      $nss_content = template("ldap_auth/ldap.conf.erb")
    }
  } else {
    $nss_ensure  = 'absent'
    $nss_service = 'stopped'
    $nss_content = undef
    $nss_notify  = undef
  }

  # Do we configure pam_ldap
  if $configure_pam {
    $pam_ensure = 'file'
  } else {
    $pam_ensure = 'absent'
  }

  file { 'nss_config':
    ensure  => $nss_ensure,
    path    => $::ldap_auth::params::nss_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $nss_content,
    require => Package[$packages],
    notify  => $nss_notify,
  }

  file { 'pam_config':
    ensure  => $pam_ensure,
    path    => $::ldap_auth::params::pam_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ldap_auth/pam_ldap.conf.erb'),
    require => Package[$packages],
  }

  # Control nslcd service
  if $::ldap_auth::params::nslcd {
    service {['nslcd','sssd']:
      ensure => $nss_service,
    }
  }

}
