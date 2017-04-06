class ApiController < ApplicationController
  before_action :current_scope
  
  def current_scope
    'blank'
  end

end

class TestController < ApiController
  
  def show
    if params[:id].present?
      test = Test.find params[:id]
      render json: test.json_for(current_scope, variable: value)
    end
  end

  def index
    Test.all.json_for(current_scope)
  end

  def create

  end

  def test_params
    params.permit(*TestSerializer.params_for(current_scope))
  end

end
