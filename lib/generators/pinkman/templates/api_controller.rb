class ApiController < ApplicationController

  def current_limit
    # default: 20
    # max: 200
    [(params[:limit] || 10).to_i, 100].min
  end
  
  def current_offset
    params[:offset] || 0
  end
  
  # TO DO: allowed_scopes
  # This method should return array of allowed scopes based on current user info.
  def allowed_scopes
    [:public]
  end
  
  def requested_scope
    begin params[:scope].to_sym rescue :public end
  end

  # You can define it according to the current user and his permissions
  # or through params[:scope] or any other way you want.
  # It's your choice.
  
  # ***** IMPORTANT *************************************************************************
  # *                                                                                       *
  # *     Never pass params[:scope] directly to serializers.                                *
  # *     params[:scope] must to be whitelisted if you are going to allow/use it.           *
  # *                                                                                       *
  # *****************************************************************************************
  
  
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