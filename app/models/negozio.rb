class Negozio
  include Mongoid::Document
  field :denominazione, type: String
  field :citta, type: String
  field :cap, type: String
  field :indirizzo, type: String
  field :lat, type: String
  field :lng, type: String
  field :parcheggio, type: String
  field :tipologia, type: String
  field :keys, type: Array
  #has_many :prodotti
  #has_many :prezzi

  def to_label
    denominazione
  end
end
