# Overview

## Configuration

Copy the file `DOT-env` to `.env`.  Edit the file `.env` and replace the values
assigned to `GITEMAIL` and `GITNAME` with the email address you use for GitHub
and your actual first and last name. This information is used to initialize the
`.gitconfig` file that is installed into `/opt/zimbra`. This file is in the
`.gitignore` file so you don't accidentally commit changes to it.

The other setting in that file `ROOT_PASSWORD` is for the webadmin interface
to BIND.  You can access this webadmin interface from a browser on your
host by going to `http://localhost:10000`. Log in with username `root`
and password with whatever is specified by `ROOT_PASSWORD`.


Here are a few special directories.

### home-zimbra

This directory is mounted into the `zcs-dev` container as `/home/zimbra`. This
follows the conventions described in the `README` file of [zm-build](https://github.com/Zimbra/zm-build).
You can checkout the various Zimbra git repositories that you are working
with in their and all that will be preserved when you restart the container.

I recommend you checkout the repos in a subdirectory of `home-zimbra` called
`zcs`, as there is a handy environment variable (`ZCS`) that points to that
directory. Note that you can set all this up after you spin up the containers.

### slash-zimbra/opt-zimbra/DOT-ssh

This directory is empty (save for a `.readme` file).  If you put your
keys here before you run the container they will be copied over to 
`/opt/zimbra/.ssh`.  This directory is in the `.gitignore` file so you
don't accidentally commit ssh keys to the git repo.

## Running the system

Just do a `docker-compose up -d`.  The first time you do this it will have
to create a base image `zimbra/zcs-ubuntu-1604:8.8.1-zcs-base`.  This base
image will have all of the `zimbra-*` packages already installed, but not
yet configured.  The actual configuration happens when the `zcs-dev` container is 
started.

Configuring Zimbra is a bit time-consuming (although we are working on that)
so even after the base image has been created, if you shut down your
containers (`docker-compose down`) it does take a while to bring them back
up again.

Once the `docker-compose up -d` command returns, the containers are running.
But the `zcs-dev` container will not be fully operational until it finishes
the run time initialization.  Issue this command if you want to follow the
initialization progress:

    docker logs -f zcs-dev

Once you see something like this, the `zcs-dev` container will be
fully operational:

    Moving /tmp/zmsetup.20170817-195059.log to /opt/zimbra/log

You can then connect to that container as follows:

    docker exec -it zcs-dev bash

And become the `zimbra` user as follows:

    su - zimbra

## Two containers are started

### bind

The container named `bind` is running bind DNS. This is used by the second container
that is running a single-node ZCS installation, all setup and ready do do development
with.  The directory `bind-data` is where all of the DNS configuration is stored,
so if you do make updates via the web interface, they will be saved and persisted
in that directory (which is mounted into this container at `/data`).

This container is based off the image `sameersbn/bind:9.9.5-20170626`.  You 
can read more about it [here](https://github.com/sameersbn/docker-bind).

### zcs-dev

This is the container that running the ZCS installation.

## Miscellaneous Notes

As mentioned above, the `zimbra/zcs-ubuntu-1604:8.8.1-zcs-base` contains
all of the `8.8.1` base `zimbra-*` packages installed, so you may tweak
the configuration file that is passed into the initialization code
however you like to control what actually gets started and configured.

That file is `slash-zimbra/zimbra-config`.

As an alternative to stopping the containers when you are not actively working
on them, you can pause them to reduce resource consumption (`docker-compose pause`)
an unpause them when you want to use them (`docker-compose unpause`).

You should edit the `/etc/hosts` file on your, um, host and add a line like this:

    127.0.0.1   zcs-dev.test

Then you can log into the web client on `zcs-dev` from a browser with the following
URL:

    https://zcs-dev.test:8443

Take a look at the `docker-compose.yml` file to see all of the port mappings.

