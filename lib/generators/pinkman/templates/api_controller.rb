class ApiController < ApplicationController

  before_action :default_limit_and_offset

  def default_limit_and_offset
    params[:limit] = 20 if params[:limit].blank?
    params[:offset] = 0 if params[:offset].blank?
  end

  # To do: define the current scope the way you want
  # Example:
  # def current_scope
  #   current_user.admin? ? :admin : :public
  # end
  def current_scope
    :public
  end

  
end