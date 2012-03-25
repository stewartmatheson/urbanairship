describe Urbanairship do
  before(:all) do
    FakeWeb.clean_registry
    FakeWebStubs.ios
  end

  describe "configuration" do
    it "enables you to configure settings correctly" do
      client = Urbanairship.configure do |config|
        config.application_key = "asdf1234"
        config.application_secret = "asdf1234"
        config.master_secret = "asdf1234"
        config.platform = :ios
      end
    end

    it "does not allow you to configure with out a platform" do 
      lambda {
        client = Urbanairship.configure do |config|
          config.application_key = "asdf1234"
          config.application_secret = "asdf1234"
          config.master_secret = "asdf1234"
        end
      }.should raise_error(RuntimeError, "Must configure platform before continuing.")
    end
  end

  context "::register_device" do
    before(:each) do
      @valid_params = {:alias => 'one'}
    end

    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.platform = :ios
      end
    }

    it "raises an error if call is made without an app key and secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.application_secret = nil
        config.platform = :ios
      end

      lambda {
        client.register_device("asdf1234")
      }.should raise_error(RuntimeError, "Must configure application_key, application_secret before continuing.")
    end

    it "uses app key and secret to sign the request" do
      subject.register_device("new_device_token")
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64('my_app_key:my_app_secret').chomp}"
    end

    it "takes and sends a device token" do
      subject.register_device("new_device_token")
      FakeWeb.last_request.path.should == "/api/device_tokens/new_device_token"
    end

    it "returns true when the device is registered for the first time" do
      subject.register_device("new_device_token").success?.should == true
    end

    it "returns true when the device is registered again" do
      subject.register_device("existing_device_token").success?.should == true
    end

    it "returns false when the authorization is invalid" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.application_secret = "my_app_secret"
        config.platform = :ios
      end
      
      client.register_device("new_device_token").success?.should == false
    end

    it "accepts an alias" do
      subject.register_device("device_token_one", @valid_params).success?.should == true
    end

    it "adds alias to the JSON payload" do
      subject.register_device("device_token_one", @valid_params)
      request_json['alias'].should == "one"
    end

    it "converts alias param to string" do
      subject.register_device("device_token_one", :alias => 11)
      request_json['alias'].should be_a_kind_of String
    end
  end

  context "::unregister_device" do
    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.platform = :ios
      end
    }

    it "raises an error if call is made without an app key and secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.application_secret = nil
        config.platform = :ios
      end


      lambda {
        client.unregister_device("asdf1234")
      }.should raise_error(RuntimeError, "Must configure application_key, application_secret before continuing.")
    end

    it "uses app key and secret to sign the request" do
      subject.unregister_device("key_to_delete")
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64('my_app_key:my_app_secret').chomp}"
    end

    it "sends the key that needs to be deleted" do
      subject.unregister_device("key_to_delete")
      FakeWeb.last_request.path.should == "/api/device_tokens/key_to_delete"
    end

    it "returns true when the device is successfully unregistered" do
      subject.unregister_device("key_to_delete").success?.should == true
      FakeWeb.last_request.body.should be_nil
    end

    it "returns false when the authorization is invalid" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.application_secret = "my_app_secret"
        config.platform = :ios
      end
      client.unregister_device("key_to_delete").success?.should == false
    end
  end

  context "::delete_scheduled_push" do
    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end
    }

    it "raises an error if call is made without an app key and master secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.master_secret = nil
        config.platform = :ios
      end

      lambda {
        client.delete_scheduled_push("123456789")
      }.should raise_error(RuntimeError, "Must configure application_key, master_secret before continuing.")
    end

    it "uses app key and secret to sign the request" do
      subject.delete_scheduled_push("123456789")
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64('my_app_key:my_master_secret').chomp}"
    end

    it "sends the key that needs to be deleted" do
      subject.delete_scheduled_push("123456789")
      FakeWeb.last_request.path.should == "/api/push/scheduled/123456789"
    end

    it "sends the key that needs to be deleted" do
      subject.delete_scheduled_push(123456789)
      FakeWeb.last_request.path.should == "/api/push/scheduled/123456789"
    end

    it "sends the alias that needs to be deleted" do
      subject.delete_scheduled_push(:alias => "alias_to_delete")
      FakeWeb.last_request.path.should == "/api/push/scheduled/alias/alias_to_delete"
    end

    it "returns true when the push notification is successfully deleted" do
      subject.delete_scheduled_push("123456789").success?.should == true
      FakeWeb.last_request.body.should be_nil
    end

    it "returns false when the authorization is invalid" do
    
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end

      client.delete_scheduled_push("123456789").success?.should == false
    end
  end

  describe "::push" do
    before(:each) do
      @valid_params = {:device_tokens => ['device_token_one', 'device_token_two'], :aps => {:alert => 'foo'}}
    end

    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end
    }

    it "raises an error if call is made without an app key and master secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.master_secret = nil
        config.platform = :ios
      end

      lambda {
        client.push(@valid_params)
      }.should raise_error(RuntimeError, "Must configure application_key, master_secret before continuing.")
    end

    it "uses app key and secret to sign the request" do
      subject.push(@valid_params)
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64('my_app_key:my_master_secret').chomp}"
    end

    it "returns true when it successfully pushes a notification" do
      subject.push(@valid_params).success?.should == true
    end

    it "returns false when the authorization is invalid" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end

      client.push(@valid_params).success?.should == false
    end

    it "adds schedule_for to the JSON payload" do
      time = Time.parse("Oct 17th, 2010, 8:00 PM UTC")
      subject.push(@valid_params.merge(:schedule_for => [time]))
      request_json['schedule_for'].should == ['2010-10-17T20:00:00Z']
    end

    it "only attempts to format schedule_for if it is a time object" do
      subject.push(@valid_params.merge(:schedule_for => ["2010-10-10 09:09:09 UTC"]))
      request_json['schedule_for'].should == ['2010-10-10T09:09:09Z']
    end

    it "returns false if urbanairship responds with a non-200 response" do
      client = Urbanairship.configure do |config|
        config.application_key = "my_app_key2"
        config.master_secret = "my_master_secret2"
        config.platform = :ios
      end

      client.push.success?.should == false
    end
  end

  describe "::batch_push" do
    before(:each) do
      @valid_params = [
        {:device_tokens => ['device_token_one', 'device_token_two'], :aps => {:alert => 'foo'}},
        {:device_tokens => ['device_token_three', 'device_token_four'], :aps => {:alert => 'bar'}}
      ]
    end

    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end
    }

    it "raises an error if call is made without an app key and master secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.master_secret = nil
        config.platform = :ios
      end

      lambda {
        client.batch_push(@valid_params)
      }.should raise_error(RuntimeError, "Must configure application_key, master_secret before continuing.")
    end

    it "uses app key and secret to sign the request" do
      subject.batch_push(@valid_params)
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64('my_app_key:my_master_secret').chomp}"
    end

    it "returns true when it successfully pushes a notification" do
      subject.batch_push(@valid_params).success?.should == true
    end

    it "returns false when the authorization is invalid" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end

      client.batch_push(@valid_params).success?.should == false
    end

    it "adds schedule_for to the JSON payload" do
      time = Time.parse("Oct 17th, 2010, 8:00 PM UTC")
      @valid_params[0].merge!(:schedule_for => [time])
      subject.batch_push(@valid_params)
      request_json[0]['schedule_for'].should == ['2010-10-17T20:00:00Z']
    end

    it "accepts strings as schedule_for values" do
      @valid_params[0].merge!(:schedule_for => ["2010-10-10 09:09:09 UTC"])
      subject.batch_push(@valid_params)
      request_json[0]['schedule_for'].should == ['2010-10-10T09:09:09Z']
    end

    it "returns false if urbanairship responds with a non-200 response" do
      client = Urbanairship.configure do |config|
        config.application_key = "my_app_key2"
        config.master_secret = "my_master_secret2"
        config.platform = :ios
      end

      client.batch_push.success?.should == false
    end
  end

  describe "::broadcast_push" do
    before(:each) do
      @valid_params = {:aps => {:alert => 'foo'}}
    end

    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end
    }
    
    it "raises an error if call is made without an app key and master secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.master_secret = nil
        config.platform = :ios
      end

      lambda {
        client.broadcast_push(@valid_params)
      }.should raise_error(RuntimeError, "Must configure application_key, master_secret before continuing.")
    end

    it "uses app key and secret to sign the request" do
      subject.broadcast_push(@valid_params)
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64('my_app_key:my_master_secret').chomp}"
    end

    it "returns true when it successfully pushes a notification" do
      subject.broadcast_push(@valid_params).success?.should == true
    end

    it "returns false when the authorization is invalid" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end
      client.broadcast_push(@valid_params).success?.should == false
    end

    it "adds schedule_for to the JSON payload" do
      time = Time.parse("Oct 17th, 2010, 8:00 PM UTC")
      @valid_params[:schedule_for] = [time]
      subject.broadcast_push(@valid_params)
      request_json['schedule_for'].should == ['2010-10-17T20:00:00Z']
    end

    it "accepts strings as schedule_for values" do
      @valid_params[:schedule_for] = ["2010-10-10 09:09:09 UTC"]
      subject.broadcast_push(@valid_params)
      request_json['schedule_for'].should == ['2010-10-10T09:09:09Z']
    end

    it "returns false if urbanairship responds with a non-200 response" do
      client = Urbanairship.configure do |config|
        config.application_key = "my_app_key2"
        config.master_secret = "my_master_secret2"
        config.platform = :ios
      end

      client.broadcast_push.success?.should == false
    end
  end


  describe "::feedback" do

    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end
    }

    it "raises an error if call is made without an app key and master secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.master_secret = nil
        config.platform = :ios
      end

      lambda {
        client.feedback(Time.now)
      }.should raise_error(RuntimeError, "Must configure application_key, master_secret before continuing.")
    end

    it "uses app key and secret to sign the request" do
      subject.feedback(Time.now)
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64('my_app_key:my_master_secret').chomp}"
    end

    it "encodes the time argument in UTC, ISO 8601 format" do
      time = Time.parse("October 10, 2010, 8:00pm")
      formatted_time = time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      subject.feedback(time)
      FakeWeb.last_request.path.should include(formatted_time)
    end

    it "accepts a string as the time argument" do
      subject.feedback("Oct 07, 2010 8:00AM UTC")
      FakeWeb.last_request.path.should include("2010-10-07T08:00:00Z")
    end

    it "returns an array of responses from the feedback API" do
      response = subject.feedback(Time.now)
      response[0].should include("device_token")
      response[0].should include("marked_inactive_on")
      response[0].should include("alias")
    end

    it "success? is false when the call doesn't return 200" do
      client = Urbanairship.configure do |config|
        config.application_key = "my_app_key2"
        config.master_secret = "my_master_secret2"
        config.platform = :ios
      end

      client.feedback(Time.now).success?.should == false
    end
  end

  context "logging" do
    let(:logger) { mock("logger", :info => true) } 

    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.master_secret = "my_master_secret"
        config.logger = logger
        config.platform = :ios
      end
    }

    it "logs request and response information when registering a device" do
      logger.should_receive(:info).with(/\/api\/device_tokens\/new_device_token/)
      subject.register_device('new_device_token')
    end

    it "logs request and response information when sending push notifications" do
      logger.should_receive(:info).with(/\/api\/push/)
      subject.push(:device_tokens => ["device_token"], :aps => {:alert => "foo"})
    end

    it "logs request and response information when sending batch push notifications" do
      logger.should_receive(:info).with(/\/api\/push\/batch/)
      subject.batch_push([:device_tokens => ["device_token"], :aps => {:alert => "foo"}])
    end

    it "logs request and response information when sending feedback requests" do
      logger.should_receive(:info).with(/\/api\/device_tokens\/feedback/)
      subject.feedback(Time.now)
    end

    it "flushes the logger buffer if it's an ActiveSupport::BufferedLogger (Default Rails logger)" do
      logger.stub(:flush).and_return("message in the buffer\n")
      logger.should_receive(:flush)
      subject.feedback(Time.now)
    end
  end

  context "request timeout" do
    let(:logger) { mock("logger", :info => true) }

    subject {  
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.master_secret = "my_master_secret"
        config.platform = :ios
        config.logger = logger
      end
    }

    it "uses a default request_timeout value of five seconds" do
      Urbanairship::Timer.should_receive(:timeout).with(5.0).and_raise(Timeout::Error)
      logger.should_receive(:error).with(/Urbanairship request timed out/)

      subject.register_device('new_device_token')
    end

    it "accepts a configured request_timeout value" do
      Urbanairship::Timer.should_receive(:timeout).with(1.23).and_raise(Timeout::Error)
      logger.should_receive(:error).with(/Urbanairship request timed out/)

      subject.request_timeout = 1.23
      subject.register_device('new_device_token')
    end

    it "should not error if a logger is not set" do
      Urbanairship::Timer.should_receive(:timeout).with(1.23).and_raise(Timeout::Error)

      client = Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.master_secret = "my_master_secret"
        config.platform = :ios
      end
      
      client.request_timeout = 1.23
      client.register_device('new_device_token')
    end
  end
end

def request_json
  JSON.parse FakeWeb.last_request.body
end
