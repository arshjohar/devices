class Device < Hashie::Mash
  include ActiveModel::Validations

  MAXIMUM_LENGTH_FOR_BRAND_AND_MODEL = 50

  module FormFactor
    CANDYBAR = 'CANDYBAR'
    SMARTPHONE = 'SMARTPHONE'
    PHABLET = 'PHABLET'
    CLAMSHELL = 'CLAMSHELL'

    def self.all
      [CANDYBAR, SMARTPHONE, PHABLET, CLAMSHELL]
    end
  end

  class AttributesValidator < ActiveModel::Validator
    MAX_NAME_LENGTH = 20
    MAX_VALUE_LENGTH = 100

    def validate(record)
      attributes = record.attributes
      attributes_names = attributes.map(&:name)
      attributes_values = attributes.map(&:value)
      if attributes.present?
        record.errors[:attributes] << 'name should be present' if attributes_names.any?(&:blank?)
        record.errors[:attributes] << 'value should be present' if attributes_values.any?(&:blank?)
        record.errors[:attributes] << 'name should not be greater than 20 characters' if attributes_names.compact.any? { |name| name.length > MAX_NAME_LENGTH }
        record.errors[:attributes] << 'value should not be greater than 100 characters' if attributes_values.compact.any? { |value| value.length > MAX_VALUE_LENGTH }
      end
    end
  end

  validates_length_of :brand, :model, maximum: 50, allow_blank: false
  validates_inclusion_of :formFactor, in: FormFactor.all

  validates_with AttributesValidator
  validate :unique_full_name

  def full_name
    "#{self.brand} #{self.model}" if (self.brand? && self.model?)
  end

  private

  def unique_full_name
    errors.add(:full_name, 'should be unique') if full_name_duplicated?
  end

  def full_name_duplicated?
    devices_with_full_name_as_current_object = DeviceReader.list_from_file.select { |device| device.full_name == self.full_name }
    devices_with_full_name_as_current_object.count > 1
  end
end
