class Api::PeopleController < ApiController

  before_action :permissions
  before_action :current_scope
  
  # To do: define the current scope the way you want.
  def current_scope
    :all
  end

  def index
    people = Person.limit(params[:limit]).offset(params[:offset])
    render json: people.json_for(current_scope)
  end

  # get api/people/:id
  def show
    render json: @person.json_for(current_scope)
  end

  # get api/people/search/:query
  def search
    if params[:query].present?
      people = Person.search(params[:query]).limit(params[:limit]).offset(params[:offset])
      render json: people.json_for(current_scope)
    end
  end

  # post api/people
  def create
    @person.assign_attributes person_params
    if @person.save
      render json: @person.json_for(current_scope)
    else
      render json: {errors: @person.errors}
    end
  end

  # put/patch api/people
  def update
    @person.assign_attributes person_params
    if @person.save
      render json: @person.json_for(current_scope)
    else
      render json: {errors: @person.errors}
    end
  end


  # delete api/people/:id
  def destroy
    @person.destroy
    render json: @person.json_for(current_scope)
  end

  protected

  # --- begin permissions  --- #

  def permissions
    unless PersonSerializer.scope(current_scope).can_access? action_name
      render json: {errors: 'You have no permission.'}
    end
  end

  # --- end permissions  --- #

  def set_objects
    if params[:id].present?
      @person = Person.find params[:id]
    else
      @person = Person.new
    end
  end

  def person_params
    if params['pink_obj']
      params["pink_obj"].keep_if {|k,v| PersonSerializer.scope(current_scope).can_write?(k)}
      params["pink_obj"].permit!
    else
      {}
    end
  end

end
