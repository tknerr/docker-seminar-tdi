
# Sample Repo for the Docker Seminar

Code repository for my HL docker seminar talk about [Test-Driven Infrastructure with Docker, ServerSpec and KitchenCI](http://slides.com/tknerr/tdi-with-kitchenci-and-docker/live#/)

Below are the steps from the "Demo Time!" part for you to follow.

## Generate the motd Cookbook

Let's create a sample "motd" cookbook:
```
chef generate cookbook motd
cd motd
```

## Run the (not yet existing) Tests

Without further ado, we can already run some tests:

 * `foodcritic .` - to run chef linting checks
 * `rspec` - to run ChefSpec unit tests
 * `kitchen test` - to run integration tests

Running `kitchen test` with VirtualBox is quite slow:
```
W:\repo\docker-seminar-tdi\motd>kitchen test 1204
-----> Starting Kitchen (v1.4.0)
-----> Cleaning up any prior instances of <default-ubuntu-1204>
-----> Destroying <default-ubuntu-1204>...
       Finished destroying <default-ubuntu-1204> (0m0.00s).
-----> Testing <default-ubuntu-1204>
-----> Creating <default-ubuntu-1204>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'opscode-ubuntu-12.04'...

...

Finished destroying <default-ubuntu-1204> (0m8.01s).
Finished testing <default-ubuntu-1204> (1m31.10s).
-----> Kitchen is finished. (1m33.65s)
```


## Let's get faster by using Docker!

Since running `kitchen test` with VirtualBox is sloooooooooooow, so let's fix that
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

## Describe what we expect in a Test

Hah, let's approach it in a test-first manner :-)

So we can describe the expected state in `test/integration/default/serverspec/default_spec.rb`:
```ruby
require 'spec_helper'

describe 'motd::default' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('/etc/motd') do
    it { should be_file }
    it { should be_mode 644 }
  end
end
```
## Run and see it failing

Now run `kitchen verify 1204` to converge the node and see the tests failing:
```
W:\repo\docker-seminar-tdi\motd>kitchen verify 1204
-----> Starting Kitchen (v1.4.0)
-----> Verifying <default-ubuntu-1204>...
$$$$$$ Running legacy verify for 'Docker' Driver
       Preparing files for transfer
       Removing /tmp/verifier/suites/serverspec
       Transferring files to <default-ubuntu-1204>
-----> Running serverspec test suite
       /opt/chef/embedded/bin/ruby -I/tmp/verifier/suites/serverspec -I/tmp/verifier/gems/gems/rspec-support-3.2.2/lib:/tmp/verifier/gems/gems/rspec-core-3.2.3/lib /opt/chef/embedded/bin/rspec --pattern /tmp/verifier/suites/serverspec/\*\*/\*_spec.rb --color --format documentation --default-path /tmp/verifier/suites/serverspec

       motd::default
         File "/etc/motd"
           should be file
           should be mode 644 (FAILED - 1)

       Failures:

         1) motd::default File "/etc/motd" should be mode 644
            Failure/Error: it { should be_mode 644 }

              /bin/sh -c stat\ -c\ \%a\ /etc/motd\ \|\ grep\ --\ \\\^644\\\$



       Finished in 0.11802 seconds (files took 0.30409 seconds to load)
       2 examples, 1 failure

       Failed examples:

       rspec /tmp/verifier/suites/serverspec/default_spec.rb:10 # motd::default File "/etc/motd" should be mode 644
```


## Fix the test by placing the motd file

Ok, so let's edit `recipes/default.rb` and add a simple motd file:
```
#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

file '/etc/motd' do
  content "hellooooooooooo"
  mode "0644"
  action :create
end
```
