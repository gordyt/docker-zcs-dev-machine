# Overview

The intent of this is to simplify getting started with ZCS development. In essense you will want to do the following:

* Run `build-image` to create an Ubuntu 16.04 server image that has all of the packages from the 8.8.1 Beta build of ZCS installed, but not configured.
* Run `run-image` to fire up a container, based on the image you just created, and finalize the ZCS install by running `zmsetup.pl`, passing in a configuration file.

See details on the `run-image` script below for more information.



## build-image

This will build a base ZCS developer image, software-only install, with the idea that we
can more quickly bring it up with all the prerequisites for doing development.
For this test I'm basing it on Ubuntu Server, 16.04.
Repository and tag are as follows:

    gordy/zcs-ubuntu-1604:8.8.1-zcs-base 

## software-install-responses

The `software-install-responses` file is used to feed responses to the command 
`./install.sh -s`.  The lines in the file are responding to the following
questions:

    Y - license?
    Y - zimbra repos?
    Y - LDAP?
    Y - LOGGER?
    Y - MTA?
    Y - DNSCACHE?
    Y - SNMP?
    Y - STORE?
    Y - APACHE?
    Y - SPELL?
    Y - MEMCACHED?
    Y - PROXY?
    Y - CHAT?
    Y - DRIVE?
    Y - IMAP?
    Y - System will be modified, continue?

## run-image

Before running this for the first time, create a user-defined Docker network for the image to use as follows:

	docker network create --driver bridge zcs

This will run the image created by the `build-image` script.  Two host directories are 
mapped into the image:

    slash-zimbra -> /zimbra
    home-zimbra -> /home/zimbra


NOTE: This takes a while (like 10 minutes or so on my mac) to complete because our configuration
process is slow.  We are working on that!  The name of the container will be `zcs-dev`.

Several ports are mapped to the host by the `run-image` script. Adjust this as required.
At the last part of the script you are asked to enter your github email address and your name.
This is used to customize the `/opt/zimbra/.gitconfig` file that gets installed.

Before running the script, take a look at the files in `slash-zimbra/opt-zimbra/`.  These
will get copied the appropriate files in `/opt/zimbra`.  You can also drop ssh keys
(or whatever) into `slash-zimbra/opt-zimbra/DOT-ssh` and they will get copied into
`/opt/zimbra/.ssh`. Note that the `.gitignore` project is set such that if you 
happen to do a `git add .` it will _not_ add anything in that directory.

You can use `C-p C-q` to switch the container to daemon mode after startup is complete.
You can pause the container when you are not using it to save resources on the host (`docker pause zcs-dev`).
Also, you should add an entry in `/etc/hosts` that maps `zcs-dev.test` to your host's IP address
so that the `HOST` header is set correctly when you want to use the Zimbra Web Client.

