require 'rails_helper'

describe DeviceReader do
  let(:expected_json_file_path) { Rails.root.join('lib', 'devices.json') }
  let(:stub_json_string) { 'stub_json_string' }
  let(:device_hashes) { [{'brand' => 'Mockia', 'model' => '5800', 'formFactor' => 'CANDYBAR',
                          'attributes' => [{'name' => 'Screen Size', 'value' => '128mm'}]},
                         {'brand' => 'Phony', 'model' => 'X11', 'formFactor' => 'SMARTPHONE',
                          'attributes' => [{'name' => 'Bluetooth', 'value' => '0.1'},
                                           {'name' => 'Raspberry', 'value' => 'Pi'}]}] }

  before do
    allow(IO).to receive(:read).with(expected_json_file_path).and_return(stub_json_string)
    allow(JSON).to receive(:parse).with(stub_json_string).and_return(device_hashes)
  end

  describe '.list_from_file' do
    it 'loads the json from file to a list of device objects' do
      list_of_device_objects = DeviceReader.list_from_file

      expect(list_of_device_objects.count).to be(device_hashes.count)
      list_of_device_objects.each { |device_object| expect(device_object).to be_an_instance_of(Device) }
    end
  end

  describe '.valid_devices' do
    it 'returns the list of valid devices' do
      allow(DeviceReader.list_from_file.first).to receive(:valid?).and_return(false)
      allow(DeviceReader.list_from_file.last).to receive(:valid?).and_return(true)

      expect(DeviceReader.valid_devices).to eq([DeviceReader.list_from_file.last])
    end
  end

  describe '.filter_by_brand' do
    it 'returns all devices with the specified brand' do
      brand = 'Phony'
      expected_devices = DeviceReader.filter_by_brand(brand)

      expected_devices.each { |device| expect(device.brand).to eq(brand) }
    end
  end

  describe '.filter_by_model' do
    it 'returns all devices with the specified model' do
      model = '5800'
      expected_devices = DeviceReader.filter_by_model(model)

      expected_devices.each { |device| expect(device.model).to eq(model) }
    end
  end

  describe '.find_by_full_name' do
    it 'returns the device with the specified full_name' do
      full_name  = 'Phony X11'
      expected_device = DeviceReader.find_by_full_name(full_name)

      expect(expected_device.full_name).to eq(full_name)
    end
  end
end