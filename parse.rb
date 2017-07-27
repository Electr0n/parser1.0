#!/usr/bin/env ruby

require 'curb'
require 'nokogiri'
require 'csv'
# debug
require 'pry'

puts "Example: https://www.petsonic.com/snacks-huesos-para-perros/"
print "Enter URL: "
page_url = STDIN.gets.chomp
print "\rEnter filename: "
filename = STDIN.gets.chomp + '.csv'
puts "\rWait please..."

CSV.open(filename, 'wb') do |csv|
  # loop to check all pages
  loop do
    html = Nokogiri::HTML(Curl.get(page_url).body_str)
    items = html.xpath('//*[@id="center_column"]/*[@class="productlist"]/*/*/*')
    items.each do |i|
      # visit each item's page
      item_url = i.at_xpath('.//*[@class="product-name"]')['href']
      item_options = Nokogiri::HTML(Curl.get(item_url).body_str)
      # get data from all item's options
      item_options.xpath('//*[@class="attribute_labels_lists"]').each do |option|
        # option name weigth/color/lenght etc
        option_name = option.xpath('.//*[@class="attribute_name"]').text.strip
        # full name
        name = option.xpath('//*[@class="product-name"]/h1/text()').text.strip + ' ' + option_name
        # price
        price = option.xpath('.//*[@class="attribute_price"]').text.strip
        # get image for current item's option
        puts name
        image = option.at_xpath('//*[@id="bigpic"]')['src']
        csv << [name, price, image]
      end
    end
    # change page url to next page
    page_url = 'https://www.petsonic.com' + html.xpath('//*[@id="pagination_next_bottom"]//a/@href').text
    # break if next page doesn't exist
    break if html.xpath('//*[@id="pagination_next_bottom"]').empty?
  end
  
puts "Finished. Check #{filename}"
end