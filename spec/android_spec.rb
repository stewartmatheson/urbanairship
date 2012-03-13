describe "Android" do
  before(:all) do
    FakeWeb.clean_registry
    FakeWebStubs.android
  end

  context "::register_device" do
    before(:each) do
      @valid_params = {:alias => 'one'}
    end

    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.platform = :android
      end
    }

    it "raises an error if call is made without an app key and secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.application_secret = nil
        config.platform = :android
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
      FakeWeb.last_request.path.should == "/api/apids/new_device_token"
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
        config.platform = :android
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
        config.platform = :android
      end
    }

    it "raises an error if call is made without an app key and secret configured" do
      client = Urbanairship.configure do |config|
        config.application_key = nil
        config.application_secret = nil
        config.platform = :android
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
      FakeWeb.last_request.path.should == "/api/apids/key_to_delete"
    end

    it "returns true when the device is successfully unregistered" do
      subject.unregister_device("key_to_delete").success?.should == true
      FakeWeb.last_request.body.should be_nil
    end

    it "returns false when the authorization is invalid" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.application_secret = "my_app_secret"
        config.platform = :android
      end
      client.unregister_device("key_to_delete").success?.should == false
    end
  end
end
