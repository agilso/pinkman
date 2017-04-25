class ApiController < ApplicationController

  before_action :default_limit_and_offset

  def default_limit_and_offset
    params[:limit] = 20 if params[:limit].blank?
    params[:offset] = 0 if params[:offset].blank?
  end
  
end