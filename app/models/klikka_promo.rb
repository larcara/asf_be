require 'open-uri'
class KlikkaPromo

  #http://www.klikkapromo.it/DettaglioInsegna.aspx?insegnaId=3
	#http://www.klikkapromo.it/DettaglioSupermercato.aspx?storeId=583
	MAIN_PAGE="http://www.klikkapromo.it"
	LOGIN_PAGE = "http://www.klikkapromo.it/WebServices/KW2_services.asmx/LoginUser"
	PRODUCT_PAGE="http://www.klikkapromo.it/coupon-offerta-ddd-ff-dd_@@@_D_0"
	attr_accessor :page, :agent, :prodotto
	
	def initialize(id_prodotto=nil)
		self.agent=Mechanize.new
    #xcoockie=AsfSetting.where(name: "klikkapromo_cookie").first
    #JSON(xcoockie.value).each do |c|
    #  cookie = Mechanize::Cookie.new(c)
    #  uri = URI.parse("http://www.klikkapromo.it")
    #  self.agent.cookie_jar.add(cookie)
    #  end
		self.agent.user_agent_alias = 'Windows IE 6'
		self.page = self.agent.get MAIN_PAGE
    return  get_product(id_prodotto) if id_prodotto

	end
	
	def get_product(id)
		self.page = self.agent.get PRODUCT_PAGE.gsub("@@@","#{id}")
		return if self.page.search(".box_sez_prod").blank?
		k=self
		prodotto={}
		prodotto["key"]="klikkapromo_#{id}"
		prodotto["marca"]= k.page.search(".box_sez_prod")[0].search("h2").text.strip
		prodotto["product"]= k.page.title.split("|")[0].downcase.gsub(/(coupon)|(sconto)|(in offerta)/, "").strip
		#prodotto["specia-price-prezzovolume"]=k.page.search(".box_sez_prod")[0].search("span")[0].children[2].text.strip
    prodotto["image"]="http://www.klikkapromo.it" + k.page.search("#MainContent_InfoBaseArticolo1_img_Articolo")[0].attributes["src"].text
		prodotto["categories"]=k.page.search("#tblVediAltriProdotti.related li").text.downcase.split("\r\n").drop(1).map{|x| x.strip unless x.strip.blank?}.compact.uniq
    prodotto["tags"] = prodotto["categories"]
    prodotto["tags"] += prodotto["product"].split(",").map{|x| x.strip.downcase}
    prodotto["tags"] << prodotto["marca"].downcase
    prodotto["categories"] << prodotto["marca"].downcase


		#prodotto["alternative-product"]=k.page.search("#MainContent_Pnl_ProdottiSimili.slider_articolo div.slider_block_container div.slider_block a").map{|l|  l.attributes["href"].text.strip.scan(/_(\d+)_D_/).join()}
=begin
		prodotto["special-price"]=[]
		tmp_prodotto={}
		k.page.search("#MainContent_pnl_Offerte table tr").each do |riga|
			if riga.attributes["class"].text =="int"
				tmp_prodotto={}
			elsif riga.attributes["class"].text =="cel_tab"
				tmp_prodotto["price"]=riga.search("td")[1].text.scan(/(\d+,\d+)/).first.join.gsub(",",".").to_f

				tmp_prodotto["negozio"]=riga.search("td").search("img")[0].attributes["src"].value.split("/").last
			elsif riga.attributes["class"].text =="cel_des"
				tmp_prodotto["date_end"]=riga.search("td").text.strip.scan(/\d\d\/\d\d\/\d\d\d\d/).join
				tmp_prodotto["um"]=k.page.search(".box_sez_prod")[0].search("span")[0].children[2].text.strip
				prodotto["special-price"] << tmp_prodotto
				tmp_prodotto={}
			else
			
			end
		end
=end
		self.prodotto=prodotto
=begin
		prodotto["special-price"].each do |neg|
			n=Negozio.where(:keys.in => [neg["negozio"]]).first
			n||=Negozio.new
			n.keys ||=[]
			n.keys << neg["negozio"]
			n.keys.uniq!
			n.save
			neg["negozio_id"]=n.id
		end
=end
#		p=Prodotto.product_form_params!(prodotto)
#    p.add_prezzo(prodotto["special-price"])

=begin
		prodotto["special-price"].each do |pr|
			ppp=p.prezzi.where(:negozio_id=>pr["negozio_id"], :data_rilevazione=>Date.today).first
			ppp||=p.prezzi.build
			ppp.keys=prodotto["key"]
			ppp.prodotto_id=p.id
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
    item=Item.find_or_create_by(name: prodotto["product"])
    item.add_to_set(:key,prodotto["key"])
    item.add_to_set(:marca,prodotto["marca"])
    item.pull(:tags,prodotto["tags"])
      prodotto["categories"].each do |c|
        item_c=Item.find_or_create_by(name: c)
        item_c.add_to_set(:cs,item.id) if item.id != item_c.id
        item.add_to_set(:ps, item_c.id) if item.id != item_c.id
      end
    return prodotto
  	end
end