class apache::base {

  file {"root directory":
    path => "/var/www"
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache2"],
  }

  file {"cgi-bin directory":
    path => "/usr/lib/cgi-bin"
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache2"],
  }

  file {"log directory":
    path => "/var/log/apache2"
    ensure => directory,
    mode => 755,
    owner => "root",
    group  => "root",
    require => Package["apache2"],
  }

  file {"logrotate configuration":
    path => "/etc/logrotate.d/apache2"
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///apache/etc/logrotate.d/apache2",
    require => Package["apache2"],
  }

  apache::module {["alias", "auth_basic", "authn_file", "authz_default", "authz_groupfile", "authz_host", "authz_user", "autoindex", "dir", "env", "mime", "negotiation", "rewrite", "setenvif", "status", "cgi"]:
    ensure => present,
    notify => Exec["apache-graceful"],
  }

  file {"default virtualhost":
    path => "/etc/apache2/sites-available/default"
    ensure => present,
    source => "puppet:///apache/etc/apache2/sites-available/default",
    seltype => "httpd_config_t",
    require => Package["apache2"],
    notify => Exec["apache-graceful"],
    mode => 644,
  }

  file {"enable default virtualhost":
    path => "/etc/apache2/sites-enabled/000-default":
    ensure => File["default virtualhost"],
    require => [Package["apache2"], File["default virtualhost"]],
    notify => Exec["apache-graceful"],
  }

  exec { "apache-graceful":
    command => "apache2ctl graceful",
    refreshonly => true,
    onlyif => "apache2ctl configtest",
  }

  file { "/etc/ssl/":
    ensure => directory,
  }

  file { "/etc/ssl/ssleay.cnf":
    source => "puppet:///apache/ssleay.cnf",
    require => File["/etc/ssl/"],
  }

  file { "/usr/local/sbin/generate-ssl-cert.sh":
    source => "puppet:///apache/generate-ssl-cert.sh",
    mode   => 755,
  }

}
