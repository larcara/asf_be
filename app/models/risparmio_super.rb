require 'open-uri'

class RisparmioSuper

	MAIN_PAGE="http://www.risparmiosuper.it/alimentari"
  PRODUCT_PAGE="http://www.risparmiosuper.it/alimentari/x/x/a_@@@"

	
	attr_accessor :agent, :page, :prodotto
	
	def initialize(id_prodotto=nil)
		self.agent=Mechanize.new
    xcoockie=AsfSetting.where(name: "risparmiosuper_cookie").first
		JSON(xcoockie.value).each do |c|
			cookie = Mechanize::Cookie.new(c)
			uri = URI.parse("http://www.risparmiosuper.it")
			self.agent.cookie_jar.add(cookie)
		end
		self.agent.user_agent_alias = 'Mac Safari'
		self.page = self.agent.get MAIN_PAGE
		return self.get_product(id_prodotto)

	end
	
	
	def get_product(idprod)
		product_page="http://www.risparmiosuper.it/alimentari/x/x/a_#{idprod}"
		begin
			self.page = self.agent.get product_page
		rescue Exception => e  
			return 
		end
		
		#return false if self.page.search("li.mainPrezzo #ctrlStoreStartPrice").blank?
		return false if self.page.search("#ctrlProductTitle").blank?
		k=self
		prodotto={}
		prodotto["key"]="risparmiosuper_#{idprod}"
		
		prodotto["marca"]= k.page.title.split("|")[1].strip
		prodotto["product"]= k.page.title.split("|")[0].strip
		prodotto["image"]=k.page.search("#topScheda img")[0].attributes["src"].text    #MainContent_InfoBaseArticolo1_img_Articolo
		prodotto["categories"]=k.page.search("#headerBread a").map{|x| x.text.downcase}
		prodotto["special-price"]=[]
		tmp_prodotto={}
		k.page.search("li.mainPrezzo").each do |riga|
			tmp_prodotto={}
			if !riga.search("#ctrlStoreStartPrice").blank?
        tmp_prodotto["price"]=riga.search("#ctrlStoreStartPrice")[0].text.scan(/(\d+.\d+)/).first.join.to_f
      elsif !riga.search("#ctrlStoreStartPriceLink").blank?
        tmp_prodotto["price"]=riga.search("#ctrlStoreStartPriceLink")[0].text.scan(/(\d+.\d+)/).first.join.to_f
      end

			tmp_prodotto["negozio"]=riga.search("#ctrlStoreLogo")[0].attributes["src"].text.scan(/http:.*\/(.*)_/).join()
			tmp_prodotto["date_end"]=riga.search("#ctrlStoreData")[0].text
			tmp_prodotto["um"]=riga.search("#ctrlStoreUnit")[0].text
			prodotto["special-price"] << tmp_prodotto
			tmp_prodotto={}
		end if !self.page.search("li.mainPrezzo #ctrlStoreStartPrice").blank?
		self.prodotto=prodotto
				
				prodotto["special-price"].each do |neg|
					n=Negozio.where(:keys.in => [neg["negozio"]]).first
					n||=Negozio.new
					n.keys ||=[]
					n.keys << neg["negozio"]
					n.keys.uniq!
					n.save
					neg["negozio_id"]=n.id
				end

    p=Prodotto.product_form_params!(prodotto)
    p.add_prezzo(prodotto["special-price"])
    p.reload


=begin
				prodotto["special-price"].each do |pr|
					ppp=p.prezzi.where( :negozio_id=>pr["negozio_id"], :data_rilevazione=>Date.today).first
					ppp||=p.prezzi.build
					ppp.prodotto_id=p.id
          ppp.keys=prodotto["key"]
					ppp.negozio_id=pr["negozio_id"]
					ppp.data_rilevazione=Date.today
					ppp.prezzo=pr["price"].to_f
					ppp.in_promozione=true
					ppp.valido_al=pr["date_end"]
					ppp.package_str=pr["um"]
					ppp.calcola_prezzo_unit
					ppp.save
				end
=end
				return prodotto["special-price"].size
			
	end
end