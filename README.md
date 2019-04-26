# Pixl8 Commandbox Commands

## Purpose

The purpose of this package is to provide common Pixl8 devops commands to the box commandline.

## Current commands

* `pixl8 mis setCredentials` - you will be supplied an API key from MIS
* `pixl8 mis setEndpoint` - you do not need to use this unless testing a local installation of MIS

## Forgebox endpoint

This package adds a custom forgebox endpoint `mis`. The idea here is that you will be able to install private pixl8 packages using:

```
box install mis:preside-ext-some-ext@^5.45.3
```

This adds the benefit of local package caching and smart version resolution along with our own private repository of packages.

## Installation

This package should be installed to local CommandBox installations with:

```
box install git+ssh://git@gitlab.pixl8.london:utilities/pixl8-commandbox-commands.git#v1.0.0
```

