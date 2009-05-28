class apache::debian inherits apache::base {

  package {"apache2":
    ensure => installed,
    alias  => "apache"
  }

  service {"apache2":
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package["apache"],
    alias => "apache"
  }

  user {"www-data":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache user",
  }

  group {"www-data":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache group",
  }

  package {["apache2-mpm-prefork", "libapache2-mod-proxy-html"]:
    ensure  => installed,
    require => Package["apache"],
  }
  
  # directory not present in lenny
  file {"/var/www/apache2-default":
    ensure  => absent,
    force => true,
  }

  case $lsbdistcodename {
    lenny: {
      File["default virtualhost"] {
        source => "puppet:///apache/etc/apache2/sites-available/default-lenny",
      }
    }
  }

  file {"/var/www/index.html":
    ensure => absent,
  }
  file {"/var/www/html":
    ensure => directory,
    require => File["/var/www"],
  }
  file {"/var/www/html/index.html":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => 644,
    content => "<html><body><h1>It works!</h1></body></html>\n",
    require => File["/var/www/html"],
  }

  file { "/etc/apache2/conf.d/servername.conf":
    content => "ServerName ${fqdn}\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }

  #TODO: remove once deployed everywhere
  exec { "sed -i '/^ServerName/d' /etc/apache2/ports.conf":
    onlyif  => "grep -q ServerName /etc/apache2/ports.conf",
    notify  => Service["apache"],
    require => Package["apache"],
  }
}
