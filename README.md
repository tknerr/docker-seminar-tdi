
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

```
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
