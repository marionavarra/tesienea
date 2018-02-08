#!/usr/bin/ruby
require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'
require 'nokogiri'      #
require "./lemmatizza2.rb"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2', # or 'postgresql' or 'sqlite3'
  database: 'info',
  username: 'root',
  password: 'stava',
  host:     'localhost',
  socket:   '/var/run/mysqld/mysqld.sock'
)

# Note that the corresponding table is 'orders'
class Alert < ActiveRecord::Base
  has_and_belongs_to_many :categories
end
class Category < ActiveRecord::Base
  has_and_belongs_to_many :alerts
end
file_lemmi = File.open("lemmatization-it.txt", "r")
linee =  file_lemmi.readlines
bodies = []
out_file = File.open("#{Time.now.strftime('%Y%m%d%H%M%S%L')}_Out_th_estrai.txt","w")
alerts = Alert.all.limit(ARGV[1]).offset(ARGV[0])

      alerts.each do |a|
      	doc = Nokogiri.HTML(a.html)
	doc.css('script').remove                             # Remove <script>…</script>
	doc.css('style').remove  				 # Remove <style>…</style>
	out=doc.text.gsub /^\s*$/m, ''                          # Remove carriage return
	out=out.gsub(/\s\s+/, "\s") 				#remove double space
	body=out.downcase.gsub /\W+/, ' '			#remove everything but the words
      	out_file.write "Alert Elaborato # " + a.id.to_s + " " + a.title
        out_file.write "lemmatizzazione # " + a.id.to_s
        bodies.push lemmatize body,linee
out_file.flush

      end     


