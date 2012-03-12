require 'base64'
require 'fakeweb'
require 'support/fake_web'

require File.join(File.dirname(__FILE__), '/../lib/urbanairship')


RSpec.configure do |config|
  config.after(:each) do
    FakeWeb.instance_variable_set("@last_request", nil)
  end
end
