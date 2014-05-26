class PrezziController < ApplicationController
  # GET /prezzi
  # GET /prezzi.json
  def index
   if params[:prodotto_id]
    @prezzi = Prodotto.find(params[:prodotto_id]).prezzi
   else
    @prezzi = Prezzo.all.limit(10)
   end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @prezzi }
    end
  end

  # GET /prezzi/1
  # GET /prezzi/1.json
  def show
    @prezzo = Prezzo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @prezzo }
    end
  end

  # GET /prezzi/new
  # GET /prezzi/new.json
  def new

    @prezzo = Prezzo.new(prodotto_id: params[:prodotto_id])
    @prezzo.attributes=params[:prezzo].except(:_id) if params[:prezzo]
    @prezzo.data_rilevazione ||= Date.today
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @prezzo }
    end
  end

  # GET /prezzi/1/edit
  def edit
    @prezzo = Prezzo.find(params[:id])
  end

  # POST /prezzi
  # POST /prezzi.json
  def create
    @prezzo = Prezzo.new(params[:prezzo])

    if params[:prezzo][:negozio_id].blank? then
      @prezzo.build_negozio(params[:negozio])
      params[:prezzo].except!(:negozio_id)
    end
    if params[:prezzo][:prodotto_id].blank? then
      @prezzo.build_prodotto(params[:prodotto])
      params[:prezzo].except!(:prodotto_id)
    end

    respond_to do |format|
      if @prezzo.save
        format.html { redirect_to edit_prezzo_url(@prezzo), notice: 'Prezzo was successfully created.' }
        format.json { render json: @prezzo, status: :created, location: @prezzo }
      else
        format.html { render action: "new" }
        format.json { render json: @prezzo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /prezzi/1
  # PUT /prezzi/1.json
  def update
    @prezzo = Prezzo.find(params[:id])
    if params[:prezzo][:negozio_id].blank? then
      @prezzo.build_negozio(params[:negozio])
      params[:prezzo].except!(:negozio_id)
    end
    if params[:prezzo][:prodotto_id].blank? then
      @prezzo.build_prodotto(params[:prodotto])
      params[:prezzo].except!(:prodotto_id)
    end
    respond_to do |format|
      if @prezzo.update_attributes(params[:prezzo]) && @prezzo.save 
        format.html { redirect_to edit_prezzo_url(@prezzo), notice: 'Prezzo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @prezzo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prezzi/1
  # DELETE /prezzi/1.json
  def destroy
    @prezzo = Prezzo.find(params[:id])
    @prezzo.destroy

    respond_to do |format|
      format.html { redirect_to prezzi_url }
      format.json { head :no_content }
    end
  end
end
