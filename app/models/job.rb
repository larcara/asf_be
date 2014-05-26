class Job
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, type: String
  field :status, type: String
  field :start_time, type: Time
  field :end_time, type: Time
  field :klass, type: String
  field :from, type: Integer
  field :to, type: Integer
  field :eseguiti, type: Integer
  field :con_prodotti, type: Integer
  field :con_prezzi, type: Integer



  def self.initialize_jobs( size=100, from=0, to=1000)
    Job.delete_all


    from.step(to,size).each do |i|
      Job.create(description: "KlikkaPromo import", status:"new", klass:"KlikkaPromo", from:(i), to: (i+size))
      Job.create(description: "RisparmioSuper import", status:"new", klass:"RisparmioSuper",  from:(i), to: (i+size))
    end
  end

end