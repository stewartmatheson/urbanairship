module Urbanairship
  class Ios < Client

    def initialize(config)
      super config
    end

    def register_device(device_token, options = {})
      body = parse_register_options(options).to_json
      do_request(:put, "/api/device_tokens/#{device_token}", :body => body, :authenticate_with => :application_secret)
    end

    def unregister_device(device_token)
      do_request(:delete, "/api/device_tokens/#{device_token}", :authenticate_with => :application_secret)
    end

    def delete_scheduled_push(param)
      path = param.is_a?(Hash) ? "/api/push/scheduled/alias/#{param[:alias].to_s}" : "/api/push/scheduled/#{param.to_s}"
      do_request(:delete, path, :authenticate_with => :master_secret)
    end

    def push(options = {})
      body = parse_push_options(options).to_json
      do_request(:post, "/api/push/", :body => body, :authenticate_with => :master_secret)
    end

    def batch_push(notifications = [])
      body = notifications.map{|notification| parse_push_options(notification)}.to_json
      do_request(:post, "/api/push/batch/", :body => body, :authenticate_with => :master_secret)
    end

    def broadcast_push(options = {})
      body = parse_push_options(options).to_json
      do_request(:post, "/api/push/broadcast/", :body => body, :authenticate_with => :master_secret)
    end

    def feedback(time)
      do_request(:get, "/api/device_tokens/feedback/?since=#{format_time(time)}", :authenticate_with => :master_secret)
    end
  end
end
