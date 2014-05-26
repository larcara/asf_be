class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :ps, type: Array
  field :cs, type: Array

  field :options
  field :marca, type: Array
  field :images, type: Array
  field :keys, type: Array
  field :tags, type: Array

  def childrens
    Item.find(self.cs) if self.cs
  end
  def parents
    Item.find(self.ps) if self.ps
  end
end