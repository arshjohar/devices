require 'rails_helper'

describe DevicesController do
  describe '#index' do
    let(:devices) { [double(Device), double(Device)] }

    context 'when no filtering is applied' do
      it 'returns the list of all valid devices' do
        allow(DeviceReader).to receive(:valid_devices).and_return(devices)

        get :index, format: :json

        expect(assigns(:devices)).to eq(devices)
        expect(response).to be_success
        expect(response).to render_template('index')
      end
    end

    context 'when filtering is applied on brand' do
      it 'returns the list of valid devices with the specified brand' do
        brand = 'some brand'
        allow(DeviceReader).to receive(:filter_by_brand).with(brand).and_return(devices)

        get :index, brand: brand, format: :json

        expect(assigns(:devices)).to eq(devices)
        expect(response).to be_success
        expect(response).to render_template('index')
      end
    end

    context 'when filtering is applied on model' do
      it 'returns the list of valid devices with the specified model' do
        model = 'some model'
        allow(DeviceReader).to receive(:filter_by_model).with(model).and_return(devices)

        get :index, model: model, format: :json

        expect(assigns(:devices)).to eq(devices)
        expect(response).to be_success
        expect(response).to render_template('index')
      end
    end
  end

  describe '#show' do
    context 'when a valid device with specified full name exists' do
      it 'returns the device' do
        device = double(Device)
        valid_full_name = 'valid full_name'
        allow(DeviceReader).to receive(:find_by_full_name).with(valid_full_name).and_return(device)

        get :show, id: valid_full_name, format: :json

        expect(assigns(:device)).to eq(device)
        expect(response).to be_success
        expect(response).to render_template('show')
      end

      context 'when a valid device with specified full name does not exist' do
        it 'returns a not found response' do
          invalid_full_name = 'invalid full_name'
          allow(DeviceReader).to receive(:find_by_full_name).with(invalid_full_name).and_return(nil)

          get :show, id: invalid_full_name, format: :json

          expect(response).to be_not_found
          expect(response).not_to render_template('show')
        end
      end
    end
  end
end