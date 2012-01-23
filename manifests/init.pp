# Puppet module to manage vmware nodes
# https://github.com/vchoi/vmware
#
# Author: Vitor Choi Feitosa <vchoi@vchoi.org>
# Based on Eric Plaster's work posted on 
# http://projects.puppetlabs.com/projects/1/wiki/VMWare_Tools.
#
class vmware::tools {

    $vmtoolstgz = 'VMwareTools-8.6.0-425873.tar.gz'

    # don't use a directory that gets wiped after every reboot!
    $workdir = '/usr/local/src/puppet-vmwaretools'

    # passed to vmware_tools_install
    $install_prefix = '/usr/local'

    # get prereqs from the distro
    $prereqs = $operatingsystem ? {
    	ubuntu => ["build-essential","linux-headers-$kernelrelease", "psmisc"],
    	debian => ["build-essential","linux-headers-$kernelrelease", "psmisc"],
	centos => ["kernel-devel-$kernelrelease", "gcc"],
    }
    package { $prereqs: ensure => present }  

    # remove open-vm-tools
    $openvmtools = ["open-vm-source", "open-vm-tools"]
    $openvmtools_desired_state = $operatingsystem ? {
	ubuntu => purged,
	debian => purged,
	centos => absent,
    }
    package { $openvmtools:
        ensure => $openvmtools_desired_state,
    }  
     
    # Copy files to workdir
    file { $workdir:
	owner => "root", mode => "700", 
	ensure => "directory"
    }
    file { "$workdir/$vmtoolstgz":
	owner => root, group => root, mode => 444,
	source => "puppet:///modules/vmware/$vmtoolstgz",
	notify => Exec['unpack vmwaretools']
    }

    exec { 'uninstall old vmwaretools':
	cwd => "/tmp",
	command => "vmware-uninstall-tools.pl",
	path => ['/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/X11R6/bin'],
	logoutput => true,
	timeout => 300,
	require => File["$workdir/$vmtoolstgz"],
	subscribe => File["$workdir/$vmtoolstgz"],
	refreshonly => true
        }

    exec { "unpack vmwaretools":
	creates => "$workdir/vmware-tools-distrib",
	cwd => $workdir,
	environment => ["PAGER=/bin/cat","DISPLAY=:9"],
	command => "/bin/tar xzf $vmtoolstgz",
	logoutput => true,
	timeout => 120,
	require => [ File["$workdir/$vmtoolstgz"], Package[$prereqs] ],
	notify => Exec['install vmwaretools']
    }
	
	case $::operatingsystem {
        ubuntu: {
            $init_creates = "/etc/init/vmware-tools.conf"
            $service_provider = 'upstart'
            file { "/etc/init.d/vmware-tools":
                ensure  => 'absent',
            }   
        }
        centos: {
            if $::operatingsystemrelease >= 6.0 {
                $init_creates = "/etc/init/vmware-tools.conf"
                $service_provider = 'upstart'
                file { "/etc/init.d/vmware-tools":
                    ensure  => 'absent',
                }   
            }
            else {
                $init_creates = "/etc/init.d/vmware-tools"
                $service_provider = 'redhat'
            }
        }
        default: {
            $init_creates = "/etc/init.d/vmware-tools"
            $service_provider = 'init'
        }
	}

    exec { "install vmwaretools":
        creates  => $init_creates,
        environment => ["PAGER=/bin/cat","DISPLAY=:9"],
        cwd      => "$workdir/vmware-tools-distrib",
        command  => "$workdir/vmware-tools-distrib/vmware-install.pl -d --prefix=$install_prefix",
        logoutput => true,
        timeout  => 300,
        require  => [ Exec["unpack vmwaretools"], Package[$prereqs] ],
    }  

    # Foi removida a dependência do reconfigure vmwaretools nos arquivos
    # para que ele consiga ser executado quando estiver sem rede (por exemplo, quando
    # faltar o módulo da vmxnet3)
    #
    # Acho que não irá gerar problemas... --vchoi 12/05/2011
    #
    exec { "reconfigure vmwaretools":
	creates => "/lib/modules/$kernelrelease/misc/vsock.o",
	onlyif => "/usr/bin/test -x $install_prefix/bin/vmware-config-tools.pl",
        environment => ["PAGER=/bin/cat","DISPLAY=:9"],
        cwd      => "$workdir/vmware-tools-distrib",
        command  => "$install_prefix/bin/vmware-config-tools.pl -d",
        logoutput => false,
        timeout  => 300,
    }  
     
    service { "vmware-tools":
        ensure => running,
        provider => $service_provider,
        enable => true,
        hasstatus => true,
        require => [ Exec["reconfigure vmwaretools"]],
    }   
}       
         
