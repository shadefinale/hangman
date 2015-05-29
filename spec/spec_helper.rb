ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'main.rb')
require 'rack/test'

RSpec.configure do |conf|
	conf.include Rack::Test::Methods
	conf.before(:suite) { DataMapper.auto_migrate! }
end