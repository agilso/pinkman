class ApiController < ApplicationController

  before_action :default_limit_and_offset

  def default_limit_and_offset
    params[:limit] = 20 if params[:limit].blank?
    params[:offset] = 0 if params[:offset].blank?
  end
  
  # TO DO: rewrite the current_scope method the way you want.
  def current_scope
    :public
  end

  # You can define it according to the current user and his permissions
  # or through params[:scope] or any other way you want.
  # It's your choice.
  
  # ***** IMPORTANT *************************************************************************
  # *                                                                                       *
  # *     Never pass params[:scope] directly to serializers.                                *
  # *     params[:scope] must to be whitelisted if you are going to allow/use it.           *
  # *     See examples bellow.                                                              *
  # *                                                                                       *
  #******************************************************************************************
  
  # --- Examples
  
  # Example 1:
  # def current_scope
  #   current_user.admin? ? :admin : :public
  # end  

  # Example 2:
  # def current_scope
  #   params[:scope].in?(['public','user_allowed','vip']) ? params[:scope].to_sym : :public
  # end

  # Example 3:
  # def current_scope
  #  your_custom_scope_verification_method?(params[:scope]) ? params[:scope].to_sym : :public
  # end
  
  # --- Settings scope in client
  
  # You can set params[:scope] value directly in the client (js/coffee). 
  # By default, every pinkman requests is made with the 'public' scope. See bellow how to change this behaviour.

  # 1. In a single object/collection
  # obj = new Pinkman.object; obj.set('scope','your_scope')

  # 2. In all instances of a given model (object or collection)
  # class YourModel extends Pinkman.object
  # YourModel.scope = 'your_scope'

  # 3. In all instances through AppObject and AppCollection
  # AppObject.scope = 'your_scope'
  # AppCollection.scope = 'your_scope'
  
end