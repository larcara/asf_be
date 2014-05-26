require 'open-uri'
class DrugstoreIt
	attr_accessor :doc, :prodotto
	SITEMAP_URL = "http://www.drugstore.it/sitemap.xml"
	
	def sitemap
		self.doc = Nokogiri::XML(open(SITEMAP_URL))
		return self.doc.version
	end
	
	def urls
		sitemap if self.doc.blank?
		self.doc.xpath('//drugstore_it:loc', 'drugstore_it' => 'http://www.sitemaps.org/schemas/sitemap/0.9')
		
	end
	def urls_prodotti
		sitemap if self.doc.blank?
		self.doc.xpath("drugstore_it:urlset/drugstore_it:url/drugstore_it:priority[text()='1.0']", 'drugstore_it' => 'http://www.sitemaps.org/schemas/sitemap/0.9').map do |p|
			p.parent.css('loc').text
		end
	end
	def parse_prodotto(p_url)
		p = Nokogiri::HTML(open(p_url))
		prodotto={}
		prodotto["product"]=p.xpath("//input[@name='product']")[0]
		prodotto["related_product"]=p.xpath("//input[@name='related_product']")[0]
		prodotto["product-name"]=p.css(".product-name")[0]
		prodotto["altri_dati"]=p.css(".product-shop").xpath("\p")[0]
		prodotto["old-price-label"]=p.css(".old-price>.price-label")[0]
		prodotto["old-price-price"]= p.css(".old-price>.price")[0]
		prodotto["old-price-prezzovolume"]=p.css(".old-price>.prezzovolume")[0]
		prodotto["special-price-label"]=p.css(".special-price>.price-label")[0]
		prodotto["special-price-price"]= p.css(".special-price>.price")[0]
		prodotto["specia-price-prezzovolume"]=p.css(".specia-price>.prezzovolume")[0]
		prodotto["descrizione"]= p.css("#tabs_descrizione_contents")[0]
		prodotto["ingredienti"]= p.css("#tabs_ingredienti_contents")[0]
		return prodotto
		
	end
end