require 'json'
require 'net/https'
require 'time'

require File.join(File.dirname(__FILE__), 'urbanairship/response')
require File.join(File.dirname(__FILE__), 'urbanairship/configuration')
require File.join(File.dirname(__FILE__), 'urbanairship/client')
require File.join(File.dirname(__FILE__), 'urbanairship/ios')
require File.join(File.dirname(__FILE__), 'urbanairship/android')

module Urbanairship

  begin
    require 'system_timer'
    Timer = SystemTimer
  rescue LoadError
    require 'timeout'
    Timer = Timeout
  end

  class << self

    #attr_accessor :application_key, :application_secret, :master_secret, :logger, :request_timeout

    def configure
      config = Configuration.new
      yield config
      config.raise_if_not_valid :platform

      if config.platform == :ios
        Urbanairship::Ios.new config
      elsif config.platform == :android
        Urbanairship::Android.new config
      end
    end
  end
end
