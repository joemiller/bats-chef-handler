Description
===========

Chef report handler that will find and execute BATS tests, similiar to and inspired
by [minitest-chef-handler](https://github.com/calavera/minitest-chef-handler)

* http://wiki.opscode.com/display/chef/Exception+and+Report+Handlers

Requirements
============

* Tested on Chef 10.14.x and 11.14.x.
* Only tested with chef-solo thus far. I do not run chef-server or hosted chef.
* Install [bats](https://github.com/sstephenson/bats). It should be in `$PATH` for the Chef run.


Installation
=====

There are two ways to use Chef Handlers.

### Method 1 (recommended)

Use the
[chef_handler cookbook by Opscode](http://community.opscode.com/cookbooks/chef_handler).
Create a recipe with the following:

    include_recipe "chef_handler"

    # Install `bats-chef-handler` gem during the compile phase
    chef_gem "bats-chef-handler"

    # load the gem here so it gets added to the $LOAD_PATH, otherwise chef_handler
    # will fail.
    require 'chef/handler/bats_handler'

    # Activate the handler immediately during compile phase
    chef_handler "Chef::Handler::BatsHandler" do
      source "chef/handler/bats_handler"
      action :nothing
    end.run_action(:enable)


### Method 2

Install the gem ahead of time, and configure Chef to use
them:

    gem install bats-chef-handler

Then add to the configuration (`/etc/chef/solo.rb` for chef-solo or
`/etc/chef/client.rb` for chef-client):

    require "chef/handler/bats_handler"
    report_handlers << Chef::Handler::BatsHandler.new

Usage
====

### Test cases

Write your BATS tests and place them together with the cookbooks they are designed to test. The handler will automatically load and execute tests based on the list of recipes that were executed during the test run.

Examples:

If the executed recipes include the recipe `foo::default`, we try to load tests from:

    <cookbook_path>/foo/tests/default_test.bats
    <cookbook_path>/foo/tests/default/*.bats

### node variables

Since BATS tests are bash scripts that execute outside of the Ruby VM, you do not have access to node variables like you would with tests written in minitest. This may or may not be an issue depending on what you're testing and there are strategies to work around this. In practice we don't expect this will be an issue for the majority of testing.

Additionally, BATS seems to be catching on as the preferred integration test approach for Chef (as seen by it's prevalance in cookbooks covered by test-kitchen testing) so we decided BATS was potentially a better test framework for Chef. 

It's also easier to run BATS tests outside of the Chef context, for example as a Sensu test or post-deploy smoketest.

### Chef run failure

If any of the tests fail, the handler raises an error to abort the Chef execution.

### Example

While developing a simple cookbook for clamav we decide to write a few integration tests. Our clamav cookbook is composed of 2 recipes

* clamav::default
* clamav::freshclam

We have created simple tests for each of them in the paths: `cookbooks/clamav/tests/default_test.bats` and `cookbooks/clamav/tests/freshclam_test.bats`:

    $ chef-solo
 
    [2013-10-01T21:38:23+00:00] INFO: *** Chef 10.14.2 ***
    ...
    [2013-10-01T21:38:39+00:00] INFO: Chef Run complete in 12.715307935 seconds
    [2013-10-01T21:38:39+00:00] INFO: Running report handlers
    [2013-10-01T21:38:39+00:00] INFO: Resources updated this run:
    [2013-10-01T21:38:39+00:00] INFO:   chef_handler[Chef::Handler::BatsHandler] (0s)
    
    [2013-10-01T21:38:39+00:00] INFO: Running test: /opt/titan/chef/cookbooks/clamav/tests/base_test.bats
    1..1
    ok 1 clamav package installed
    [2013-10-01T21:38:40+00:00] INFO: Running test: /opt/titan/chef/cookbooks/clamav/tests/freshclam_test.bats
    1..4
    ok 1 clamav-update package installed
    ok 2 /etc/sysconfig/freshclam exists and is enabled
    ok 3 /etc/cron.d/clamav-update cron job exists
    ok 4 virus database should exist (if not, see /etc/cron.d/clamav-update)
    [2013-10-01T21:38:41+00:00] INFO: Report handlers complete

Credit
====

The idea and much of the code to make this happen was borrowed straight out of (minitest-chef-handler)[https://github.com/calavera/minitest-chef-handler] by David Calavera. We simply wanted the same thing but with BATS tests.

TODO
====

* It would be nice to support a similar path structure to what test-kitchen's BATS busser expects so that tests were easily and automatically executed in the bats-handler context and test-kitchen context.
* Only call the bats binary once with all `.bats` files as arguments so that there is a single TAPS output. Not currently supported by BATS but would be an easy patch.

License
=======

Licensed under the MIT license. See `LICENSE` file for details.

Joe Miller <https://github.com/joemiller>, <https://twitter.com/miller_joe>
