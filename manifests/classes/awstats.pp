class apache::awstats {

  package { "awstats":
    ensure => installed
  }

  file { ["/etc/awstats/awstats.conf",
         "/etc/awstats/awstats.conf.local",
         "/etc/awstats/awstats.model.conf",
         "/etc/awstats/awstats.localhost.localdomain.conf",
         "/etc/awstats/awstats.${fqdn}.conf"]:
    ensure  => absent,
    require => Package[awstats]
  }

  case $operatingsystem {

    Debian: {
      cron { "update all awstats virtual hosts":
        command => "/usr/share/doc/awstats/examples/awstats_updateall.pl -awstatsprog=/usr/lib/cgi-bin/awstats.pl -confdir=/etc/awstats now > /dev/null",
        user    => "root",
        minute  => [0,10,20,30,40,50],
        require => Package[awstats]
      }

      file { "/etc/cron.d/awstats":
        ensure => absent,
      }
    }

    RedHat: {

      # awstats RPM installs its own cron in /etc/cron.hourly/awstats

      file { "/usr/share/awstats/wwwroot/cgi-bin/":
        seltype => "httpd_sys_script_exec_t",
        recurse => true,
        require => Package["awstats"],
      }

      file { "/var/lib/awstats/":
        seltype => "httpd_sys_script_ro_t",
        recurse => true,
        require => Package["awstats"],
      }

      file { "/etc/httpd/conf.d/awstats.conf":
        ensure  => absent,
        require => Package["awstats"],
        notify  => Service["apache"],
      }
    }

    default: { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

}
