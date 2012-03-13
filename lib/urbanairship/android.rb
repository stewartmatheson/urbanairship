module Urbanairship
  class Android < Client

    def initialize(config)
      super config
    end

    def register_device(device_token, options = {})
      body = parse_register_options(options).to_json
      do_request(:put, "/api/apids/#{device_token}", :body => body, :authenticate_with => :application_secret)
    end

    def unregister_device(device_token)
      do_request(:delete, "/api/apids/#{device_token}", :authenticate_with => :application_secret)
    end
  end
end
