require 'json'
require 'net/https'
require 'time'

require File.join(File.dirname(__FILE__), 'urbanairship/response')

module Urbanairship
  begin
    require 'system_timer'
    Timer = SystemTimer
  rescue LoadError
    require 'timeout'
    Timer = Timeout
  end
  
  @attributes ||= {}

  class << self

    def self.thread_safe_attr_accessor(*attrs)
      puts @attributes
      attrs.each do |attribute|
        send :define_method, "#{attribute.to_s}=" do |value|
          @attributes[attribute] = value 
        end
        
        send :define_method, attribute.to_s do 
          @attributes[attribute]
        end
      end
    end

    thread_safe_attr_accessor :application_key, :application_secret, :master_secret, :logger

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

    def request_timeout=(value)
      @attributes['request_timeout'] = value
    end

    private

    def do_request(http_method, path, options = {})
      verify_configuration_values(:application_key, options[:authenticate_with])

      klass = Net::HTTP.const_get(http_method.to_s.capitalize)

      request = klass.new(path)
      request.basic_auth Urbanairship.application_key, Urbanairship.send("#{options[:authenticate_with]}")
      request.add_field "Content-Type", "application/json"
      request.body = options[:body] if options[:body]

      Timer.timeout(request_timeout) do
        start_time = Time.now
        response = http_client.request(request)
        log_request_and_response(request, response, Time.now - start_time)
        Urbanairship::Response.wrap(response)
      end
    rescue Timeout::Error
      logger.error "Urbanairship request timed out after #{request_timeout} seconds: [#{http_method} #{request.path} #{request.body}]"
      Urbanairship::Response.wrap(nil, :body => {:error => 'Request timeout'}, :code => '503')
    end

    def verify_configuration_values(*symbols)
      absent_values = symbols.select{|symbol| Urbanairship.send(symbol).nil? }
      raise("Must configure #{absent_values.join(", ")} before making this request.") unless absent_values.empty?
    end

    def http_client
      Net::HTTP.new("go.urbanairship.com", 443).tap{|http| http.use_ssl = true}
    end

    def parse_register_options(hash = {})
      hash[:alias] = hash[:alias].to_s unless hash[:alias].nil?
      hash
    end

    def parse_push_options(hash = {})
      hash[:schedule_for] = hash[:schedule_for].map{|elem| process_scheduled_elem(elem)} unless hash[:schedule_for].nil?
      hash
    end

    def log_request_and_response(request, response, time)
      return if logger.nil?

      time = (time * 1000).to_i
      http_method = request.class.to_s.split('::')[-1]
      logger.info "Urbanairship (#{time}ms): [#{http_method} #{request.path}, #{request.body}], [#{response.code}, #{response.body}]"
      logger.flush if logger.respond_to?(:flush)
    end

    def format_time(time)
      time = Time.parse(time) if time.is_a?(String)
      time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    def process_scheduled_elem(elem)
      if elem.class == Hash
        elem.merge!(:scheduled_time => format_time(elem[:scheduled_time]))
      else
        format_time(elem)
      end
    end

    def request_timeout
      @attributes['request_timeout'] || 5.0
    end

  end
end
