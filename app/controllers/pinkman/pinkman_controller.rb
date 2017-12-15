class Pinkman::PinkmanController < ActionController::Base
  def hello
    redirect_to '/' unless Rails.env.in? ['development','test']
    render layout: nil
  end
end