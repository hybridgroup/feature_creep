$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'feature_creep'
require 'feature_creep/redis_datastore'
require 'feature_creep/default_config'
require 'rspec'
require 'bourne'
require 'redis'
require 'pry'

RSpec.configure do |config|
  config.mock_with :mocha
  config.before { Redis.new.flushdb }
end
