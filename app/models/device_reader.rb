class DeviceReader
  # TODO: Put the json_file_path in a config, and inject it in a constructor.
  class << self
    # Assuming that the file is huge, and hence memoizing/caching the results of the methods. To bust the cache, we may
    # check the modified time of the file, and compare it with the last modified time. Or, just use md5 hash.
    def list_from_file
      @device_list ||= JSON.parse(IO.read(json_file_path)).map { |device_hash| Device.new(device_hash) }
    end

    def valid_devices
      @valid_devices ||= list_from_file.select(&:valid?)
    end

    def filter_by_brand(brand)
      valid_devices.select { |device| device.brand == brand }
    end

    def filter_by_model(model)
      valid_devices.select { |device| device.model == model }
    end

    def find_by_full_name(full_name)
      valid_devices.find { |device| device.full_name == full_name }
    end

    private
    def json_file_path
      Rails.root.join('lib', 'devices.json')
    end
  end
end