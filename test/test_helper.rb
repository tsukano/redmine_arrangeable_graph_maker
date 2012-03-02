
# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

require 'redmine'
require 'gruff'
require 'yaml'

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path
