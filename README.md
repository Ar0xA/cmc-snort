cmc-snort
============

Configuration templates for snort.


Puppet Snort Module
===================

Module for configuring Snort.

Tested on CentOS 7.x with Puppet 4.4.x, Snort 2.9.8.3 and daq 2.0.6 

Pull requests welcome.

Installation
------------

Clone this repo to a git directory under your Puppet modules directory:

    git clone https://github.com/ConclusionMC/cmc-snort.git


Usage
-----

The `snort::sensor` class installs the snort application:

    include snort::sensor

By default `snort::sensor` assumes the rules files are managed as file resources by the Puppet Master.
If your sensor manages its own ruleset set the `$norules` option as in:

    'snort::sensor':
      gbl_home_net => '[10.10.0.0/8]',
      norules => true;

Many other `snort.conf` options are configurable via parameters. Please see `sensor.pp` for full details.

This sensor module assumes you have Snort and daq available as packages for Puppet to install from your local repo server.

Note: if you do not specify a home_net, puppet will calculate the local networks from the interfaces and enter those in the snort.conf.

Rules
-----

Snort rules should be placed in modules/snort/files/rules. 
The VRT and community rules source is: https://www.snort.org/downloads

IP reputation rules are also included in modules/snort/files/rules/ipreputation; No alert on this the local.rules needs added:

  alert ( msg: "REPUTATION_EVENT_BLACKLIST"; sid: 1; gid: 136; rev: 1; metadata: rule-type preproc ; classtype:bad-unknown; )
  alert ( msg: "REPUTATION_EVENT_WHITELIST"; sid: 2; gid: 136; rev: 1; metadata: rule-type preproc ; classtype:bad-unknown; )

Source for IP reputation rules is: https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset

Fork info
---------
Forked from the no longer maintained https://github.com/packs/puppet-snort
