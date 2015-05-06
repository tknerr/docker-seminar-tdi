
# Sample Repo for the Docker Seminar

Let's create a sample "motd" cookbook:
```
chef generate cookbook motd
cd motd
```

Without further ado, we can already run some tests:

 * `foodcritic .` - to run chef linting checks
 * `rspec` - to run ChefSpec unit tests
 * `kitchen test` - to run integration tests

Running `kitchen test` with VirtualBox is sloooooooooooow, so let's fix that
by creating a `.kitchen.docker.yml` file with the necessary overrides for the
docker provisioner:

```yml
---
driver:
  name: docker

driver_config:
  provision_command:
    - curl -L https://www.opscode.com/chef/install.sh | bash -s -- -v 12.3.0
  require_chef_omnibus: false
  use_sudo: false
```

Note that we installed the omnibus chef client via `provision_command`, which
basically adds a `RUN` entry in the Dockerfile and thus we get it cached in
a docker layer :-)

In order to use it, you have to `set KITCHEN_LOCAL_YAML=.kitchen.docker.yml`
and then run `kitchen test` again.

Weeeeeeeeee, much faster, and we can even run it in parallel via `kitchen test -c` now! :-)
```
W:\repo\docker-seminar-tdi\motd>kitchen test -c
-----> Starting Kitchen (v1.4.0)
-----> Cleaning up any prior instances of <default-ubuntu-1204>
-----> Cleaning up any prior instances of <default-centos-65>
-----> Destroying <default-ubuntu-1204>...
-----> Destroying <default-centos-65>...
       Finished destroying <default-ubuntu-1204> (0m0.00s).
       Finished destroying <default-centos-65> (0m0.00s).
-----> Testing <default-ubuntu-1204>
-----> Testing <default-centos-65>
-----> Creating <default-ubuntu-1204>...
-----> Creating <default-centos-65>...

...

Finished testing <default-ubuntu-1204> (0m17.68s).
Finished testing <default-centos-65> (0m23.27s).
-----> Kitchen is finished. (0m25.49s)
```
