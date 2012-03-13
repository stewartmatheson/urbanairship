describe Urbanairship::Response do
  before do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
  end

  context "#code" do
    
    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.platform = :ios
      end
    }

    before do
      FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/device_tokens/new_device_token", :status => ["201", "Created"])
      FakeWeb.register_uri(:put, /bad_key\:my_app_secret\@go\.urbanairship\.com/, :status => ["401", "Unauthorized"])
      @response = subject.register_device("new_device_token")
    end

    it "should be set correctly on new registraion token" do
      @response.code.should eql '201'
    end

    it "should set correctly on unauthhorized" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.application_secret = "my_app_secret"
        config.platform = :ios
      end

      client.register_device("new_device_token").code.should eql '401'
    end
 end

  context "#success?" do
    subject {
      Urbanairship.configure do |config|
        config.application_key = "my_app_key"
        config.application_secret = "my_app_secret"
        config.platform = :ios
      end
    }

    before do
      FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/device_tokens/new_device_token", :status => ["201", "Created"])
      FakeWeb.register_uri(:put, /bad_key\:my_app_secret\@go\.urbanairship\.com/, :status => ["401", "Unauthorized"])
      @response = subject.register_device("new_device_token")
    end

    it "should be true with good key" do
      @response.success?.should == true
    end

    it "should be false with bad key" do
      client = Urbanairship.configure do |config|
        config.application_key = "bad_key"
        config.application_secret = "my_app_secret"
        config.platform = :android
      end
      client.register_device("new_device_token").success?.should == false
    end
  end

  context "body array accessor" do
    let(:client) {
      Urbanairship.configure  do |config|
        config.application_secret = "my_app_secret"
        config.application_key = "my_app_key"
        config.master_secret = "my_master_secret"
        config.platform = :android
      end
    }

    subject { client.feedback(Time.now) }

    before do
      FakeWeb.register_uri(:get, /my_app_key\:my_master_secret\@go\.urbanairship.com\/api\/device_tokens\/feedback/, :status => ["200", "OK"], :body => "[{\"device_token\":\"token\",\"marked_inactive_on\":\"2010-10-14T19:15:13Z\",\"alias\":\"my_alias\"},{\"device_token\":\"token2\",\"marked_inactive_on\":\"2010-10-14T19:15:13Z\",\"alias\":\"my_alias\"}]")
    end

    it "should set up correct indexes" do
      subject[0]['device_token'].should eql "token"
      subject[1]['device_token'].should eql "token2"
    end
  end

  context "non array response" do

    let(:client) {
      Urbanairship.configure  do |config|
        config.application_secret = "my_app_secret"
        config.application_key = "my_app_key"
        config.master_secret = "my_master_secret"
        config.platform = :android
      end
    }

    subject { client.feedback(Time.now) }

    before do
      FakeWeb.register_uri(:get, /my_app_key\:my_master_secret\@go\.urbanairship.com\/api\/device_tokens\/feedback/, :status => ["200", "OK"], :body => "{\"device_token\":\"token\",\"marked_inactive_on\":\"2010-10-14T19:15:13Z\",\"alias\":\"my_alias\"}")
    end

    it "should set up correct keys" do
      subject['device_token'].should eql "token"
    end
  end
end
