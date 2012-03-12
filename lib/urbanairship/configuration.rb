module Urbanairship
  class Configuration
    attr_accessor :application_key, :application_secret, :master_secret, :platform, :logger

    def raise_if_not_valid(*symbols)
      absent_values = symbols.select{|symbol| instance_variable_get("@#{symbol}").nil? }
      raise("Must configure #{absent_values.join(", ")} before continuing.") unless absent_values.empty?
    end
  end
end
