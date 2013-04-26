class ldap_auth::params{

  case $osfamily {
    'RedHat': {
      if $operatingsystemrelease >= 6 {
        $packages      = ['nss-pam-ldap','pam-ldap']
        $nss_config    = '/etc/nslcd.conf'
        $nslcd         = true
        $configure_nss = true
        $configure_pam = false
      }else{
        $packages      = ['nss-ldap','pam-ldap']
        $nss_config    = '/etc/ldap.conf'
        $configure_nss = true
        $configure_pam = false
      }
      $pam_config = '/etc/pam_ldap.conf'
    }
    'Debian': {
      $packages = 'libnss_ldap'
    }
  }
}
