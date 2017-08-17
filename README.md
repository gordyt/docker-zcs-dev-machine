# Overview

The intent of this is to simplify getting started with ZCS development. 

## Configuration

Edit the file `.env` and replace the values assigned to `GITEMAIL` and
`GITNAME` with the email address you use for GitHub and your actual
first and last name. This information is used to initialize the `.gitconfig`
file that is installed into `/opt/zimbra`. This file is in the `.gitignore`
file so you don't accidentally commit changes to the file.

Here are a few special directories.

### home-zimbra

This directory is mounted into the `zcs-dev` container as `/home/zimbra`. This
follows the convetions described in the `README` file of
[zm-build](https://github.com/Zimbra/zm-build).
You can checkout the various Zimbra git repositories that you are working
with in their and all that will be preserved when you restart the container.

I recommend you checkout the repos in a subdirectory of `home-zimbra` called
`zcs`, as there is a handy environment variable (`ZCS`) that points to that
directory. Note that you can set all this up after you spin up the containers.

### slash-zimbra/opt-zimbra/DOT-ssh

This directory is empty (save for a `.readme` file).  If you put your
keys here before you run the container they will be copied over to 
`/opt/zimbra/.ssh`.  This directory is in the `.gitignore` file so you
don't accidentally commit ssh keys to git.

## Running the system

Just do a `docker-compose up -d`.  The first time you do it it will have
to create a base image `zimbra/zcs-ubuntu-1604:8.8.1-zcs-base`.  This base
image will have all of the `zimbra-*` packages already installed, but not
yet configured.  The actual configuration happens when the container is 
started.

Configuration Zimbra is a bit time-consuming (although we are working on that)
so even after the base image has been created, if you stop your containers
it does take a while to restart them.

Two containers are created:

### bind

The container named `bind` is running bind DNS. This is used by the second container
that is running a single-node ZCS installation, all setup and ready do do development
with.  The directory `bind-data` is where all of the DNS configuration is stored,
so if you do make updates via the web interface, they will be saved and persisted
in that directory (which is mounted into this container at `/data`).

### zcs-dev

This is the container that running the ZCS installation.


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

# Bind DNS configuration

The base configuration files are in the `bind-config` folder.

* `named.conf.local` - This gets copied to `/etc/bind/named.conf.local`, with no modifications.
* `zcs-dev.test.hosts` - This gets copied to `/var/lib/bind/zcs-dev.test.hosts`.  In the process, the
  string ZCSDEVIP is replaced with the actual IPV4 address that is assigned by Docker.

