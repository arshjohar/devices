require 'rails_helper'

describe Device do
  describe 'validations' do
    let(:valid_device_hash) { {'brand' => 'brand', 'model' => 'model', 'formFactor' => Device::FormFactor::CLAMSHELL} }

    context 'when attributes are not present' do
      before do
        empty_attributes = []
        allow_any_instance_of(Device).to receive(:attributes).and_return(empty_attributes)
      end

      it { should ensure_length_of(:brand).is_at_most(50) }
      it { should ensure_length_of(:model).is_at_most(50) }
      it { should ensure_inclusion_of(:formFactor).in_array(Device::FormFactor.all) }

      context 'when full name is not unique' do
        it 'is invalid' do
          first_device = Device.new(valid_device_hash)
          second_device = Device.new(valid_device_hash)
          allow(DeviceReader).to receive(:list_from_file).and_return([first_device, second_device])

          expect(first_device).to be_invalid
          expect(second_device).to be_invalid
        end
      end

      context 'when full name is unique' do
        it 'is valid' do
          first_device = Device.new(valid_device_hash)
          second_device = Device.new(valid_device_hash.merge({'model' => 'changed_model'}))
          allow(DeviceReader).to receive(:list_from_file).and_return([first_device, second_device])

          expect(first_device).to be_valid
          expect(second_device).to be_valid
        end
      end
    end

    context 'when attributes are present' do
      context 'and other validations pass' do
        context 'and some attributes do not have names' do
          it 'is invalid' do
            device = Device.new(valid_device_hash.merge({'attributes' => [{'name' => 'abc', 'value' => 'cde'},
                                                                          {'value' => 'efg'}]}))

            expect(device).to be_invalid
          end
        end

        context 'and some attributes do not have values' do
          it 'is invalid' do
            device = Device.new(valid_device_hash.merge({'attributes' => [{'name' => 'abc', 'value' => 'cde'},
                                                                          {'name' => 'efg'}]}))

            expect(device).to be_invalid
          end
        end

        context 'and name is greater than 20 characters' do
          it 'is invalid' do
            device = Device.new(valid_device_hash.merge({'attributes' => [{'name' => 'abc', 'value' => 'cde'},
                                                                          {'name' => 'e' * 21}]}))

            expect(device).to be_invalid
          end
        end

        context 'and value is greater than 100 chars' do
          it 'is invalid' do
            device = Device.new(valid_device_hash.merge({'attributes' => [{'name' => 'abc', 'value' => 'cde'},
                                                                          {'value' => 'e' * 101}]}))

            expect(device).to be_invalid
          end
        end

        context 'and all attributes related validations pass' do
          it 'is valid' do
            device = Device.new(valid_device_hash.merge({'attributes' => [{'name' => 'abc', 'value' => 'cde'},
                                                                          {'name' => 'xyz', 'value' => 'efg'}]}))

            expect(device).to be_valid
          end
        end
      end
    end
  end

  describe '#full_name' do
    context 'when brand is present' do
      let(:brand) { 'brand1' }

      context 'when model is present' do
        let(:model) { 'model1' }

        it 'returns the full name' do
          expected_full_name = "#{brand} #{model}"

          expect(Device.new({'brand' => brand, 'model' => model}).full_name).to eq(expected_full_name)
        end
      end

      context 'when model is not present' do
        it 'returns nil' do
          expect(Device.new({'brand' => brand}).full_name).to be_nil
        end
      end
    end

    context 'when brand is not present' do
      context 'when model is not present' do
        it 'returns nil' do
          expect(Device.new({}).full_name).to be_nil
        end
      end

      context 'when model is present' do
        let(:model) { 'model1' }

        it 'returns nil' do
          expect(Device.new({'model' => model}).full_name).to be_nil
        end
      end
    end
  end
end

describe Device::FormFactor do
  describe '.all' do
    it 'returns the list of allowed form factors' do
      expect(subject.all).to match_array(%w(CANDYBAR PHABLET SMARTPHONE CLAMSHELL))
    end
  end
end
