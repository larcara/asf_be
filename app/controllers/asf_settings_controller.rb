class AsfSettingsController < ApplicationController
  # GET /asf_settings
  # GET /asf_settings.json
  def index
    @asf_settings = AsfSetting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @asf_settings }
    end
  end

  # GET /asf_settings/1
  # GET /asf_settings/1.json
  def show
    @asf_setting = AsfSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asf_setting }
    end
  end

  # GET /asf_settings/new
  # GET /asf_settings/new.json
  def new
    @asf_setting = AsfSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asf_setting }
    end
  end

  # GET /asf_settings/1/edit
  def edit
    @asf_setting = AsfSetting.find(params[:id])
  end

  # POST /asf_settings
  # POST /asf_settings.json
  def create
    @asf_setting = AsfSetting.new(params[:asf_setting])

    respond_to do |format|
      if @asf_setting.save
        format.html { redirect_to @asf_setting, notice: 'Asf setting was successfully created.' }
        format.json { render json: @asf_setting, status: :created, location: @asf_setting }
      else
        format.html { render action: "new" }
        format.json { render json: @asf_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /asf_settings/1
  # PUT /asf_settings/1.json
  def update
    @asf_setting = AsfSetting.find(params[:id])

    respond_to do |format|
      if @asf_setting.update_attributes(params[:asf_setting])
        format.html { redirect_to @asf_setting, notice: 'Asf setting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asf_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asf_settings/1
  # DELETE /asf_settings/1.json
  def destroy
    @asf_setting = AsfSetting.find(params[:id])
    @asf_setting.destroy

    respond_to do |format|
      format.html { redirect_to asf_settings_url }
      format.json { head :no_content }
    end
  end
end
