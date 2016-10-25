[![Build Status](https://travis-ci.org/icann-dns/puppet-portshaker.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-portshaker)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/portshaker.svg?maxAge=2592000)](https://forge.puppet.com/icann/portshaker)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/portshaker.svg?maxAge=2592000)](https://forge.puppet.com/icann/portshaker)
# portshaker

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with portshaker](#setup)
    * [What portshaker affects](#what-portshaker-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with portshaker](#beginning-with-portshaker)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Manage client and server](#manage-client-and-server)
    * [Ansible client](#portshaker-client)
    * [Ansible Server](#portshaker-server)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs portshaker and can also manage the custom scripts, host script and custom modules directories

## Setup

### What portshaker affects

* installs portshaker 

### Setup Requirements 

* puppetlabs-stdlib 4.12.0
* icann-tea 0.2.5

### Beginning with portshaker

The logstash host and the SSL certificate source locations are both mandadory parameters

```puppet
class {'::portshaker': }
```

## Reference

### Classes

#### Public Classes

* [`portshaker`](#class-portshaker)

#### Private Classes

* [`portshaker::params`](#class-portshakerparams)

#### Class: `portshaker`

Main class

##### Parameters 

* `package` (String, Default: 'portshaker'): The package to install
* `mirror_base_dir` (Tea::Absolutepath, Default: '/var/cache/portshaker'): Base directory for mirrored Ports Trees
* `ports_trees` (Array[String] Default: ['default']): Array of ports directories to merge.
* `default_ports_tree` (Tea::Absolutepath, Default: '/usr/ports'): ull path of the directory where the 'default' ports tree is located.
* `default_merge_from` (Tea::Absolutepath, Default: freebsd): The source to use for the default tree.
* `default_poudriere_tree` (Default: default): name of the poudriere_tree to use
* `poudriere_ports_mountpoint` (Tea::Absolutepath, Default: /usr/local/poudriere/ports): The directory where poudriere(8) ports directory are mounted.
* `git_branch` (String, Default: master): git branch to use if there is a git uri
* `use_zfs` (Boolean, Default: false): Weather we should use ZFS
* `use_poudriere` (Boolean, Default: false): Weather we should use poudriere
* `portshaker_conf_file` (Tea::Absolutepath, Default: /usr/local/etc/portshaker.conf): where to store the config file
* `add_cron` (Boolean, Default: true): weather to add cron jobs
* `git_clone_uri` (Optional[Tea::HTTPUrl], Default: undef):  git uri to merge

## Limitations

This module is tested on FreeBSD 10 

