class NegoziController < ApplicationController
  # GET /negozi
  # GET /negozi.json
  def index
    @negozi = Negozio.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @negozi }
    end
  end

  # GET /negozi/1
  # GET /negozi/1.json
  def show
    @negozio = Negozio.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @negozio }
    end
  end

  # GET /negozi/new
  # GET /negozi/new.json
  def new
    @negozio = Negozio.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @negozio }
    end
  end

  # GET /negozi/1/edit
  def edit
    @negozio = Negozio.find(params[:id])
  end

  # POST /negozi
  # POST /negozi.json
  def create
    @negozio = Negozio.new(params[:negozio])

    respond_to do |format|
      if @negozio.save
        format.html { redirect_to @negozio, notice: 'Negozio was successfully created.' }
        format.json { render json: @negozio, status: :created, location: @negozio }
      else
        format.html { render action: "new" }
        format.json { render json: @negozio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /negozi/1
  # PUT /negozi/1.json
  def update
    @negozio = Negozio.find(params[:id])

    respond_to do |format|
      if @negozio.update_attributes(params[:negozio])
        format.html { redirect_to @negozio, notice: 'Negozio was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @negozio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /negozi/1
  # DELETE /negozi/1.json
  def destroy
    @negozio = Negozio.find(params[:id])
    @negozio.destroy

    respond_to do |format|
      format.html { redirect_to negozi_url }
      format.json { head :no_content }
    end
  end
end
