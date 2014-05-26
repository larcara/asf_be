namespace :asf do
  desc "import klikkapromo manuale"
  task :klikkapromo , [:n1, :n2] => :environment do |t, args|
    puts args.inspect
    time_start=Time.now

    n1, n2=args.n1.to_i, args.n2.to_i

    k=KlikkaPromo.new(n1)
    n2.times do |i|
      k.get_product(n1 + i)
      puts "#{i} / #{n2}"
    end
    puts "#{n2} in #{Time.now - time_start} sec"
  end
  desc "import batch from job"
  task :exec_import_job => :environment do |t, args|

    j=Job.where(status: "new").first
   if j.blank?
    puts "nessun job da eseguire!"
   else
    #counter=[j.to-j.from,0,0,0] #tot, current, prodotti, prezzi
    j[:eseguiti]=0
    j[:con_prodotti]=0
    j[:con_prezzi]=0
    j[:status]="working"
    j[:start_time]=start_time=Time.now
    j.save
    _klass=j.klass.constantize
    x=_klass.new(j.from)
    (j.from..j.to).each do |i|
      #p=Prodotto.where("")
      r=x.get_product(i)
      j[:eseguiti]+=1
      j[:con_prodotti]+=1 if r
      j[:con_prezzi]+=1 if r && r > 1
      j.save
    end
    j[:status]="endend"
    j[:end_time]=end_time=Time.now
    j.save
    items= j.to-j.from
    elapsed=(end_time - start_time).to_i
    puts "#{j.from}-->#{j.to}: #{items} in #{elapsed} sec (#{items/elapsed})"
    end
  end
end