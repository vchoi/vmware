Puppet Module to Manage vmware nodes
====================================

Description
-----------

Puppet module to handle installation, upgrade and reconfiguration of vmware
tools on vmware virtual nodes.

Tested on:
* Ubuntu 10.04
* Centos 5.6

You should be able to get the latest version o this module on:
https://github.com/vchoi/vmware

Use
---

Use something like this in your classes:

 case $virtual {
     vmware: { include vmware::tools }
     default: {}
 }


Installation
------------
* Install Module
* Copy VMWare Tools tarball to the module directory

Troubleshoting
--------------
It should work without problems, but just in case you get into trouble... These are the most common problems:

* Check you have another version of vmware tools installed. The module tries to remove old versions but in case it doesn't, do it yourself. :)
* Old kernels are usually removed from repositories. You may need to upgrade your kernel to the latest release so apt/yum are able to find packages for your kernel-headers.


Author
------

Written by Vitor Choi Feitosa <vchoi@vchoi.org>, based on work from 
Eric Plaster (http://projects.puppetlabs.com/projects/1/wiki/VMWare_Tools)

License
-------

Licensed under GPL v2.0
