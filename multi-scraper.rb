require 'nokogiri'
require 'open-uri'

# price scraper for "http://www.justenergy.com/"
# looks heavyhanded but want to be able to test methods offline and use local files, etc.

# returns an array of hashes like  [{:price=>8.59, :product=>"electric"}] 
class JustEnergyScraper
  attr_reader :url, :page_data

  def initialize( base_url = "http://www.justenergy.com/",
    resource_path = "residential/products-and-rates/", query_zip = 10001 )
    @query_zip = query_zip.to_s
    @base_url   =   base_url
    @resource_path = resource_path
    @page_data
    calc_url
    pull_in_page @url
    
    
  end
  def calc_url()
    query_params = (@query_zip == "") ? "" : "?zip=#{@query_zip}"
    puts query_params

    @url = @base_url << @resource_path << query_params
  end


  def pull_in_page(url = @url)
    @page_data = Nokogiri::HTML(open(url))
  
  end
  def pluck_prices(data = @page_data)

    # TODO - get terms and conditions
    # TODO - get renewable percentage
    # TODO - get if available attributes of the renewable power, e.g. local wind

    # hone in on tree where out content is
    # everything is under divs of class .products-inner
    # there's a .product div for each item for sale
    # each .product has a .title that can be checked for keywords
    # and also a .price that contains the price
    # 
    tree = data.css(".product")
    return nil if tree.size == 0

    nodes = []

    tree.each_with_index do |node, index|
      nodes[index] = { price: find_price(node), product: find_prod_name(node)}
    end
    return nodes

  end
  def find_price(nok_node)
    nok_node.css(".price").text.strip.to_f
  end


  def find_prod_name(nok_node)
    return "gas" if nok_node.text.downcase.match("gas")
    return "electric" if nok_node.text.downcase.match("electric")
  end


end

#TESTS
#########


# can launch file from irb
# irb -r /path/to/this/file
# ---in my case---
# irb -r /Users/tonysemeraro/Desktop/scraper/multi-scraper.rb 

# defaults to pulling in NYC 10001
# testy = JustEnergyScraper.new
# 
# full_data = JustEnergyScraper.new("http://www.justenergy.com/","residential/products-and-rates/", 10001 )
# puts full_data.pluck_prices


# test file with single price
#file_rate = JustEnergyScraper.new("some/file/path", "", "")
#--in my case--
#> file_rate = JustEnergyScraper.new("/Users/tonysemeraro/Desktop/scraper/just-energy/products-and-rates-10001.html","","")
#puts file_rate.pluck_prices

# test file with multiple rates
# multi_rate = JustEnergyScraper.new("some/other/file/path", "", "")
#puts multi_rate.pluck_prices





