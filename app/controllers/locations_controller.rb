class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :edit, :update, :destroy]
  # GET /locations
  # GET /locations.json
  def index
    most_recent = Location.select("max(id) as id").group(:truck_id)
    @locations = Location.where(id: most_recent).includes(:truck)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/new
  def new
    @location = Location.new(truck_id: params["truck_id"])
    authorize_user_by_location
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)
    return if authorize_user_by_location
    respond_to do |format|
      if @location.save
        format.html { redirect_to truck_path(id: @location.truck_id), notice: 'Location was successfully created.' }
        format.json { render json: truck_path(id: @location.truck_id), status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end

  private
    def set_location
      @location = Location.find(params[:id])
    end

    def location_params
      params.require(:location).permit(:truck_id, :longitude, :latitude)
    end

    def authorize_user_by_location
      redirect_to(root_path, notice: "You have to be logged in to do that" ) if !@location.truck || @location.truck.user_id != current_user.id
    end
end
