class DevicesController < ApplicationController
  def index
    if params[:brand].present?
      @devices = DeviceReader.filter_by_brand(params[:brand])
    elsif params[:model].present?
      @devices = DeviceReader.filter_by_model(params[:model])
    else
      @devices = DeviceReader.valid_devices
    end
  end

  # using show for name as full_name is unique for a device, and hence, can be inferred as the unique id in case of
  # resourceful routes
  def show
    @device = DeviceReader.find_by_full_name(params[:id])
    head :not_found if @device.nil?
  end
end