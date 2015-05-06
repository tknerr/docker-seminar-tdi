
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
