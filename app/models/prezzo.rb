
class Prezzo

  UM_CONV={}
  UM_CONV["kg"]={"kg"=>1,"g"=>1000, "hg"=>10}
  UM_CONV["kg."]=UM_CONV["kg"]
  UM_CONV["g"]={"g"=>1,"kg"=>0.001, "hg"=>0.01}
  UM_CONV["gr"]=UM_CONV["g"]
  UM_CONV["gr."]=UM_CONV["g"]
  UM_CONV["ml"]={"ml"=>1,"cl"=>10, "dl"=>100, "l"=>100}
  UM_CONV["cl"]={"ml"=>0.1,"cl"=>1, "dl"=>10, "l"=>10}
  include Mongoid::Document
  include Mongoid::Timestamps
  field :prezzo, type: Float
  field :um, type: String
  field :prezzo_um, type: String
  field :in_promozione, type: String
  field :note, type: String
  field :valido_dal , type: String #Date
  field :valido_al , type: String #Date
  field :con_carta, type: String
  field :data_rilevazione, type: Date
#  field :prodotto_id, type: String
  field :negozio_id, type: String
  field :package, type: Hash
  field :prezzo_unit, type: Hash

  field :keys, type: Array



  #belongs_to :negozio
  embedded_in :prodotto
  
  #accepts_nested_attributes_for :negozio
  
  #after_save :calcola_prezzo_unit


  def negozio
    Negozio.find(negozio_id).first if negozio_id
  end
  def negozio=(attributes)
    if n=negozio
       n.attributes=attributes
    else
      n=Negozio.create(attributes)
      n.save
      self[:negozio_id]=n.id
    end
  end

  def package_str
    package.to_a.map{|x| "#{x[1]} #{x[0]}"}.join("\r\n")
  end
  def package_str=(value)


    self.package={}
    value.split("\r\n").sort.each do |l|
      ll=l.split(" ")
      self.um||=ll[1]
      self.package[ll[1]]=ll[0].to_f
	  UM_CONV[ll[1]].each do |k,v|
		self.package[k]=ll[0].to_f * v
	  end if UM_CONV[ll[1]]
    end  
  end

 def calcola_prezzo_unit
  k_prezzo_unit={}
  package.each do |k,v|
    prz=self.prezzo.to_f/v
    k_prezzo_unit[k]=prz if prz > 0.1
  end if package
  self.prezzo_unit= k_prezzo_unit
  self.prezzo_um=k_prezzo_unit[self.um]
 end

  def listino
    prezzo_unit.to_a.map{|x| "#{"%.2f" %  x[1]} al #{x[0]}; " if x[1] > 0.1}
  end

 
def to_label

  "#{data_rilevazione}: <br> #{self.listino.join("<br/>")}"
end



end
