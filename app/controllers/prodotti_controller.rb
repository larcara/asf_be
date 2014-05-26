class ProdottiController < ApplicationController

  def categorie
    @tags=Prodotto.tagcloud.map{|t| [t["value"],t["_id"]] if t["value"]>1}.compact.sort{|a,b| b[0]<=>a[0]}[0...30]
  end

  def tipo
    if params[:id].blank? || params[:tipo].blank?
      render json: {}
      return
    end
    if params[:id].is_a?(String)
      p=Prodotto.find(params[:id])
      r=p.update_attribute(:stelle, params[:tipo])
      ids=Prodotto.where(marca: p.marca).map(&:id)
      render json: {esito: r,marca: p.marca, ids: ids}
      return
    else
      pp=Prodotto.where(:id.in => params[:id])
      pp.each do |p|
        p.update_attribute(:stelle, params[:tipo])
      end
      render json: {esito: true}
      return
    end
  end


  def unisci
    if params[:ids]
      @prodottos = Prodotto.where(:id.in=>params[:ids]).to_a
      @prodotto = @prodottos.shift
      @prodottos.each do |prodotto|
        prodotto.prezzi.each{|p| p["prodotto_id"]=@prodotto.id; p.save; @prodotto.prezzi << p}
        @prodotto[:keys]+= prodotto.keys
        @prodotto[:keys]= @prodotto.keys.uniq
        @prodotto[:images] ||= {}
        @prodotto[:images]=@prodotto[:images].merge(prodotto.images) if prodotto.images
        prodotto.delete
      end
      @prodotto.save
      render json: true
      return
    elsif params[:destroy_all]=="CANCELLATUTTOSONOLUCA"
      Prodotto.delete_all
      Prezzo.delete_all
      Negozio.delete_all
      Job.delete_all
      Job.initialize_jobs
      redirect_to prodotti_path()
      return
    else
      redirect_to prodotti_path(tags: params[:tags])
    end
  end
  # GET /prodottos
  # GET /prodottos.json
  def index
	if !params[:tags].blank?
    params[:tags].downcase!
    tags=params[:tags].split(",").map{|x| x.split(" ")}.flatten
    tags=tags-AsfSetting.stopwords(tags)
    params[:tags]=tags.join(",")
		@prodottos = Prodotto.where(:tags.all =>tags )
    @prodottos = @prodottos.where(stelle: params[:tipo]) if !params[:tipo].blank?
    @prodottos = @prodottos.where(:disabilitato.in => [0,nil]) if params[:disabilitato].blank?

    @prodottos = @prodottos.gt(prezzi_counter: 1 ) if params[:prezzi] && params[:prezzi]=="1"

  else
		@prodottos = Prodotto.where(:tags.all =>[] )
	end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @prodottos }
    end
  end

  # GET /prodottos/1
  # GET /prodottos/1.json
  def show
    @prodotto = Prodotto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @prodotto }
    end
  end

  # GET /prodottos/new
  # GET /prodottos/new.json
  def new
    @prodotto = Prodotto.new
    @prodotto.prezzi.build
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @prodotto }
    end
  end

  # GET /prodottos/1/edit
  def edit
    @prodotto = Prodotto.find(params[:id])
    @prodotto.prezzi.build
  end

  # POST /prodottos
  # POST /prodottos.json
  def create
    @prodotto = Prodotto.new(params[:prodotto])
    if params[:prodotto][:negozio_id].blank?
      params[:prodotto].except!(:negozio_id)
    else
      params[:prodotto].except!(:negozio_attributes)
    end
    @prodotto.prezzi.each do |pz|
        pz.negozio_id=@prodotto.negozio_id
        pz.data_rilevazione=@prodotto.data_rilevazione
        pz.in_promozione=@prodotto.in_promozione
        pz.valido_dal=@prodotto.valido_dal
        pz.valido_al=@prodotto.valido_al
        pz.con_carta=@prodotto.con_carta
    end
    respond_to do |format|
      if @prodotto.save
        format.html { redirect_to edit_prodotto_url(@prodotto), notice: 'Prodotto was successfully created.' }
        format.json { render json: @prodotto, status: :created, location: @prodotto }
      else
        format.html { render action: "new" }
        format.json { render json: @prodotto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /prodottos/1
  # PUT /prodottos/1.json
  def update
    @prodotto = Prodotto.find(params[:id])
    if params[:prodotto][:negozio_id].blank?
      params[:prodotto].except!(:negozio_id)
      @prodotto.negozio_id=nil
    else
      params[:prodotto].except!(:negozio_attributes)
    end
    respond_to do |format|
      if @prodotto.update_attributes(params[:prodotto])
        format.html { redirect_to edit_prodotto_url(@prodotto), notice: 'Prodotto was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @prodotto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prodottos/1
  # DELETE /prodottos/1.json
  def destroy
    @prodotto = Prodotto.find(params[:id])
    if @prodotto[:disabilitato]==1
      @prodotto.update_attribute(:disabilitato, 0)
    else
      @prodotto.update_attribute(:disabilitato, 1)
    end
    respond_to do |format|
      format.html { redirect_to prodotti_url }
      format.json { render json: @prodotto[:disabilitato]==1 }
    end
  end

  def popover_images

    @prodotto = Prodotto.find(params[:id])
    render layout: false
  end
end
