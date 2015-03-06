class java-development-env {
  include apt

  apt::ppa { "ppa:webupd8team/java": }

  $solr_url = "http://apache.mirror.digionline.de/lucene/solr/5.0.0/solr-5.0.0.tgz"

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  exec { 'apt-get update 2':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Ppa["ppa:webupd8team/java"], Package["git-core"] ],
  }

  # install necessary ubuntu packages to setup the environment
  package { ["vim",
             "curl",
             "git-core",
             "expect",
             "bash"]:
    ensure => present,
    require => Exec["apt-get update"],
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  package { ["oracle-java7-installer"]:
    ensure => present,
    require => Exec["apt-get update 2"],
  }

  exec {
    "accept_license":
    command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    cwd => "/home/vagrant",
    user => "vagrant",
    path    => "/usr/bin/:/bin/",
    require => Package["curl"],
    before => Package["oracle-java7-installer"],
    logoutput => true,
  }

  Exec {
    path  => "${::path}",
  }

  group { "puppet":
    ensure  => present,
  }

  package { "acpid":
    ensure  => installed,
  }

  package { "supervisor":
    ensure  => installed,
  }

  package { "wget":
    ensure  => installed,
  }

  user { "vagrant":
    ensure    => present,
    comment   => "Tomcat User",
    home      => "/home/vagrant",
    shell     => "/bin/bash",
  }

  group { "solr":
        ensure => present,
  }
  
  user { "solr":
        ensure     => present,
        gid        => "solr",
        membership => minimum,
        shell      => "/bin/bash",
        require    => Group["solr"]
  }




  exec { "get_solr":
	cwd => "/tmp",
	command => "wget ${solr_url} -O solr.tar.gz > /opt/.solr_get_solr",
	creates => "/opt/.solr_get_solr",
	timeout => 900,
	require => Package["wget"],
	notify => Exec["extract_solr"],
	logoutput => "on_failure"
  }

  exec { "extract_solr":
	cwd => "/opt",
	command => "tar zxf /tmp/solr.tar.gz ; mv solr* solr",
	creates => "/opt/solr",
	require => Exec["get_solr"],
	notify => Exec["initd_solr"],
	refreshonly => true,
  }

  exec { "initd_solr":
	cwd => "/opt",
	command => "cp /opt/solr/bin/init.d/solr /etc/init.d/solr; chmod 755 /etc/init.d/solr; chown root:root /etc/init.d/solr; mkdir /var/solr; cp /opt/solr/bin/solr.in.sh /var/solr; update-rc.d solr defaults; update-rc.d solr enable; /etc/init.d/solr start",
	require => Exec["extract_solr"],
	notify => Exec["start_solr"],
	refreshonly => true,
  }

   file { "/opt/solr":
	ensure => directory,
	owner => "solr",
	mode => 0755,
	recurse => true,
	require => Exec["extract_solr"],
  }


  exec { "start_solr":
	cwd => "/opt",
	command => "/etc/init.d/solr start",
	require => Exec["initd_solr"],
	refreshonly => true,
  }

  exec { "update_supervisor":
    command     => "supervisorctl update",
    refreshonly => true,
  }


}

include java-development-env
