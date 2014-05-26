class AsfSetting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :value
  index ({name: 1, value: 1})

  #after_save :check_stopwords

  def self.stopwords(tags)

    #AsfSetting.where(name: "stopwords", :value.in => tags).map{|x| x.value}
    AsfSetting.where(name: "stopwords").map{|x| x.value.split(",")}.flatten
  end

  #def check_stopwords
    #if self.name="stopwords"
    #  @@stopwords = AsfSetting.where(name: "stopwords").map{|x| x.value}
    #end
  #end

  def self.init_stopwords
      p=File.expand_path("stopwords.txt","config")
      x=File.open(p)
      i=0
      x.readlines.first.split(" ").each do |x|
          puts x
          AsfSetting.where(name: "stopwords", value: x).create
       end


      return true
  end
end