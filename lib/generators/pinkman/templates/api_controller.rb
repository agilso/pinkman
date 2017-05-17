class ApiController < ApplicationController

  before_action :default_limit_and_offset

  def default_limit_and_offset
    params[:limit] = 20 if params[:limit].blank?
    params[:offset] = 0 if params[:offset].blank?
  end

  # TO DO: rewrite the current_scope method the way you want.

  # You can define it according to the current user and his permissions
  # or through params[:scope] or any other way you want.
  # It's your choice.
  
  # See some common examples and important securities notes below.
  
  # Example 1:
  # def current_scope
  #   current_user.admin? ? :admin : :public
  # end  

  # Example 2:
  # def current_scope
  #   params[:scope] == 'public' ? :public : (current_user.admin? ? :admin : :public)
  # end

  # Example 3:
  # def current_scope
  #  your_scope_verification_method?(params[:scope]) ? params[:scope].to_sym : :public
  # end
  
  # ***** IMPORTANT **********************************************************************************
  # *                                                                                                *
  # *     params[:scope] must to be whitelisted if you are going to allow/use it.                    *
  # *                                                                                                *
  # **************************************************************************************************
  
  # You can set params[:scope] value in the client (js/coffee). 

  # 1. In a single object/collection
  # obj = new Pinkman.object; obj.set('scope','public')

  # 2. In all instances of a given model (object or collection)
  # class YourModel extends Pinkman.object
  # YourModel.scope = 'public'

  # 3. In all instances through AppObject and AppCollection
  # AppObject.scope = 'public'
  # AppCollection.scope = 'public'

  def current_scope
    :public
  end
  
end