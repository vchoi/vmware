Puppet Module to Manage vmware nodes
====================================

Description
-----------

Puppet module to handle installation, upgrade and reconfiguration of vmware
tools on vmware virtual nodes.

You should be able to get the latest version o this module on:
https://github.com/vchoi/vmware

Use
---

Use something like this in your classes:

 case $virtual {
     vmware: { include vmware::tools }
     default: {}
 }

Author
------

Written by Vitor Choi Feitosa <vchoi@vchoi.org>, based on work from 
Eric Plaster (http://projects.puppetlabs.com/projects/1/wiki/VMWare_Tools)

License
-------

Licensed under GPL v2.0
