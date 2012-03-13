module Urbanairship
  class Client
    def initialize(config)
      @configuration = config
    end
  
    attr_accessor :request_timeout

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

    private

    def parse_register_options(hash = {})
      hash[:alias] = hash[:alias].to_s unless hash[:alias].nil?
      hash
    end

    def do_request(http_method, path, options = {})
      @configuration.raise_if_not_valid(:application_key, options[:authenticate_with]) 
      
      klass = Net::HTTP.const_get(http_method.to_s.capitalize)

      request = klass.new(path)
      request.basic_auth @configuration.application_key, @configuration.send(options[:authenticate_with])
      request.add_field "Content-Type", "application/json"
      request.body = options[:body] if options[:body]

      Timer.timeout(request_timeout) do
        start_time = Time.now
        response = http_client.request(request)
        log_request_and_response(request, response, Time.now - start_time)
        Urbanairship::Response.wrap(response)
      end
    rescue Timeout::Error
      @configuration.logger.error "Urbanairship request timed out after #{request_timeout} seconds: [#{http_method} #{request.path} #{request.body}]"
      Urbanairship::Response.wrap(nil, :body => {:error => 'Request timeout'}, :code => '503')
    end

    def http_client
      Net::HTTP.new("go.urbanairship.com", 443).tap{|http| http.use_ssl = true}
    end

    def log_request_and_response(request, response, time)
      return if @configuration.logger.nil?

      time = (time * 1000).to_i
      http_method = request.class.to_s.split('::')[-1]
      @configuration.logger.info "Urbanairship (#{time}ms): [#{http_method} #{request.path}, #{request.body}], [#{response.code}, #{response.body}]"
      @configuration.logger.flush if @configuration.logger.respond_to?(:flush)
    end

    def parse_push_options(hash = {})
      hash[:schedule_for] = hash[:schedule_for].map{|elem| process_scheduled_elem(elem)} unless hash[:schedule_for].nil?
      hash
    end

    def process_scheduled_elem(elem)
      if elem.class == Hash
        elem.merge!(:scheduled_time => format_time(elem[:scheduled_time]))
      else
        format_time(elem)
      end
    end

    def format_time(time)
      time = Time.parse(time) if time.is_a?(String)
      time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    def request_timeout
      @request_timeout || 5.0
    end

  end
end
