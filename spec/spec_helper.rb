$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'pry'
require 'rspec'
require 'bourne'
require 'redis'
require 'feature_creep'
require 'feature_creep/redis_data_store'
require 'feature_creep/simple_strategy'

RSpec.configure do |config|
  config.mock_with :mocha
  # Redis Data Store
  config.before { Redis.new.flushdb }
end
