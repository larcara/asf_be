class Prodotto
  include Mongoid::Document
  include Mongoid::Timestamps
  #field :data_rilevazione, type: Date
  field :tipo_prodotto, type: String
  field :stelle, type: Integer
  field :nome_commerciale, type: String
  field :marca, type: String
  field :tags, type: Array 

  #field :prezzo, type: Float
  #field :in_promozione, type: String

  field :codice_a_barre, type: String
  field :codici_identificativi, type: Hash
  field :etichetta, type: String
  field :prod_alternativi, type: Array

  field :keys, type: Array
  field :images, type: Hash

  field :prezzi_counter, type: Float
  field :disabilitato, type: Integer
  index ({disabilitato: 1})
  index ({keys: 1})
  index ({tags: 1})
  #belongs_to :negozio
  embeds_many :prezzi




  #accepts_nested_attributes_for :negozio
  #accepts_nested_attributes_for  :prezzi, reject_if: :all_blank, allow_destroy: true
  
  attr_accessor :data_rilevazione , :in_promozione, :valido_dal , :valido_al ,:con_carta
  def link(key)
     k=key.split("_")
     if k[0]=="risparmiosuper"
       RisparmioSuper::PRODUCT_PAGE.gsub("@@@", k[1])
     elsif k[0]=="klikkapromo"
       KlikkaPromo::PRODUCT_PAGE.gsub("@@@", k[1])
     else
       ""
     end
  end
  def to_label
    "#{marca} #{nome_commerciale}"
  end

  def self.product_form_params!(prodotto)
    p=Prodotto.where(:keys.in => [prodotto["key"]]).first
    p||=Prodotto.new
    p["keys"] ||=[]
    p["keys"] << prodotto["key"]
    p["keys"].uniq!
    p["nome_commerciale"]=prodotto["product"]
    p["marca"]=prodotto["marca"].downcase
    p.images||={}
    p.images[prodotto["key"]]=prodotto["image"]
    tags = []
    tags += prodotto["categories"]
    tags += prodotto["product"].downcase.gsub(/\W/, " ").split(" ")
    tags += prodotto["marca"].downcase.gsub(/\W/, " ").split(" ")
    tags=tags.map{|x| x.gsub(/\W/, " ").downcase.strip.split(" ")}.flatten.uniq
    tags=tags.map{|x| x.gsub(/\d/, "").downcase.strip.split(" ")}.flatten.uniq
    tags = tags - AsfSetting.stopwords(tags) #STOPWORDS_IT
    #tags = tags - YAML.load(AsfSetting.where(name: "stopwords").first.value)
    p.tags=tags
    p.save
    return p
  end

  def self.tagcloud(filter=[])
		xmap=
<<eos
			function() {if (!this.tags) {return;}
				for (index in this.tags) {emit(this.tags[index], 1);}}
eos
    xreduce=
<<eos
		 function(previous, current) {var count = 0;
          for (index in current) {count += current[index];}
          return count;}
eos
		if filter.blank?
      @tags  = self.map_reduce(xmap, xreduce).out(inline: true)
    else
      @tags  = Prodotto.where(:tags.all =>filter).map_reduce(xmap, xreduce).out(inline: true)
    end
    return @tags
  end

  def update_from_keys
    self.keys.each do |k|
      kk=KlikkaPromo.new(1)
      rr=RisparmioSuper.new(1)
      k=k.split("_")
      puts k.inspect
      if k[0]=="klikkapromo"
         puts kk.get_product k[1]
      elsif k[0]=="risparmiosuper"
        puts rr.get_product k[1]
      else
        puts "invalid keys"
      end
    end

  end

  def self.normalizza(tags=[])
     counter=0
     if tags
       prodotti=Prodotto.all
     else
       prodotti=Prodotto.where(:tags.in=>tags)
     end

     prodotti.each do |p|

     pp=[]
     counter+=1
     puts "#{counter} #{p.id.to_s}"
     pp=Prodotto.where(:tags.all=>p.tags).to_a   if p.tags
     if pp.size > 1
       puts "elaboro #{p.tags} per #{pp.size} occorrenze"
       p0=pp.shift
       pp.each do |p2|
         p0<<p2
         p0.save
         p2.delete
       end
       p0[:tags]=p0.tags- AsfSetting.stopwords(p0.tags)
       p0.save
     end
    end
  end

  def normalizza

      pp=Prodotto.where(:tags.all=>self.tags).to_a   if self.tags
      if pp.size > 1
        puts "elaboro #{self.tags} per #{pp.size} occorrenze"
        p0=pp.shift
        pp.each do |p2|
          p0<<p2
          p0.save
          p2.delete
        end
        p0[:tags]=p0.tags- AsfSetting.stopwords(p0.tags)
        p0.save
      end

  end

  def <<(newp)
      self.prezzi << newp.prezzi
      self[:keys]+= newp.keys
      self[:keys]= self.keys.uniq
      self[:images] ||= {}
      self[:images]=self[:images].merge(newp.images) if newp.images
      self.save
  end

  def add_prezzo(pr_array)
    #self[:prezzi]||= []
    pr_array.each do |pr|
      puts "elaboro prezzo #{pr}"
      ppp=self.prezzi.build(
          negozio_id: pr["negozio_id"],
          data_rilevazione: Date.today,
          prezzo: pr["price"].to_f,
          in_promozione: true,
          valido_al: pr["date_end"],
          package_str: pr["um"]
      )
     ppp.calcola_prezzo_unit
     ppp.save!
    end
    self[:prezzi_counter]=0
    self.update_attribute(:prezzi_counter, self.prezzi.size) if self.prezzi
  end

  def self.disabilita_marca(marca)
    Prodotto.where(marca: marca).each{|p| p.update_attribute(:disabilitato, 1)}
  end

end
