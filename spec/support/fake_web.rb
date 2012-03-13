module FakeWebStubs
  
  def self.ios

    # register_device
    FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/device_tokens/new_device_token", :status => ["201", "Created"])
    FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/device_tokens/existing_device_token", :status => ["200", "OK"])
    FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/device_tokens/device_token_one", :status => ["201", "Created"])
    FakeWeb.register_uri(:put, /bad_key\:my_app_secret\@go\.urbanairship\.com/, :status => ["401", "Unauthorized"])

    # unregister_device
    FakeWeb.register_uri(:delete, /my_app_key\:my_app_secret\@go\.urbanairship.com\/api\/device_tokens\/.+/, :status => ["204", "No Content"])
    FakeWeb.register_uri(:delete, /bad_key\:my_app_secret\@go\.urbanairship.com\/api\/device_tokens\/.+/, :status => ["401", "Unauthorized"])

    common
  end

  def self.android
    # register_device
    FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/apids/new_device_token", :status => ["201", "Created"])
    FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/apids/existing_device_token", :status => ["200", "OK"])
    FakeWeb.register_uri(:put, "https://my_app_key:my_app_secret@go.urbanairship.com/api/apids/device_token_one", :status => ["201", "Created"])
    FakeWeb.register_uri(:put, /bad_key\:my_app_secret\@go\.urbanairship\.com/, :status => ["401", "Unauthorized"])

    # unregister_device
    FakeWeb.register_uri(:delete, /my_app_key\:my_app_secret\@go\.urbanairship.com\/api\/apids\/.+/, :status => ["204", "No Content"])
    FakeWeb.register_uri(:delete, /bad_key\:my_app_secret\@go\.urbanairship.com\/api\/apids\/.+/, :status => ["401", "Unauthorized"])

    common
  end

  def self.common
    FakeWeb.allow_net_connect = false

    # push
    FakeWeb.register_uri(:post, "https://my_app_key:my_master_secret@go.urbanairship.com/api/push/", :status => ["200", "OK"])
    FakeWeb.register_uri(:post, "https://my_app_key2:my_master_secret2@go.urbanairship.com/api/push/", :status => ["400", "Bad Request"])
    FakeWeb.register_uri(:post, /bad_key\:my_master_secret\@go\.urbanairship\.com/, :status => ["401", "Unauthorized"])

    # batch_push
    FakeWeb.register_uri(:post, "https://my_app_key:my_master_secret@go.urbanairship.com/api/push/batch/", :status => ["200", "OK"])
    FakeWeb.register_uri(:post, "https://my_app_key2:my_master_secret2@go.urbanairship.com/api/push/batch/", :status => ["400", "Bad Request"])

    # broadcast push
    FakeWeb.register_uri(:post, "https://my_app_key:my_master_secret@go.urbanairship.com/api/push/broadcast/", :status => ["200", "OK"])
    FakeWeb.register_uri(:post, "https://my_app_key2:my_master_secret2@go.urbanairship.com/api/push/broadcast/", :status => ["400", "Bad Request"])

    # delete_scheduled_push
    FakeWeb.register_uri(:delete, /my_app_key\:my_master_secret\@go\.urbanairship.com\/api\/push\/scheduled\/[0-9]+/, :status => ["204", "No Content"])
    FakeWeb.register_uri(:delete, /my_app_key\:my_master_secret\@go\.urbanairship.com\/api\/push\/scheduled\/alias\/.+/, :status => ["204", "No Content"])
    FakeWeb.register_uri(:delete, /bad_key\:my_master_secret\@go\.urbanairship.com\/api\/push\/scheduled\/[0-9]+/, :status => ["401", "Unauthorized"])

    # feedback
    FakeWeb.register_uri(:get, /my_app_key\:my_master_secret\@go\.urbanairship.com\/api\/device_tokens\/feedback/, :status => ["200", "OK"], :body => "[{\"device_token\":\"token\",\"marked_inactive_on\":\"2010-10-14T19:15:13Z\",\"alias\":\"my_alias\"}]")
    FakeWeb.register_uri(:get, /my_app_key2\:my_master_secret2\@go\.urbanairship.com\/api\/device_tokens\/feedback/, :status => ["500", "Internal Server Error"])
  end

end
