#!/usr/bin/ruby
require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'
require 'nokogiri'      #
require "./rimuovi_non_in_dizionario.rb"
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
  has_many :entries
end
class Category < ActiveRecord::Base
  has_and_belongs_to_many :alerts
end
class Entry < ActiveRecord::Base
  belongs_to :alert
end

file_dizionario = File.open("dizionario.txt", "r")
linee =  file_dizionario.readlines
bodies = []

out_file = File.open("#{Time.now.strftime('%Y%m%d%H%M%S%L')}_Out_th_dizionario.txt","w")
out_file.write "id,text,guasto,manutenzione,maltempo\n"
alerts = Alert.all.limit(ARGV[1]).offset(ARGV[0])
alerts.each do |a|
doc=""
#      	doc = Nokogiri.HTML(a.html)
#	doc.css('script').remove                             # Remove <script>…</script>
#	doc.css('style').remove  				 # Remove <style>…</style>
	a.entries.each do |entry|
		doc+=entry.entry 
	end
  
  p "Documento da analizzare " + doc unless doc.nil?
    unless doc.nil?
		out=doc.gsub /^\s*$/m, ''                       # Remove carriage return
		out=out.gsub(/\s\s+/, "\s")  				#remove double space
		body=out.downcase.gsub(/\W+/, ' ')			#remove everything but the words
		#out_file.write "Da ripulire: " + body
    else
	   out_file.write "documento non trovato"
	end
	#out_file.write "\nAlert Elaborato # " + a.id.to_s + " " + a.title
    #out_file.write "\nripulito # " + rimuovi_non_in_dizionario(body,linee) unless body.nil?
    #bodies.push + bodies.last
	out = rimuovi_non_in_dizionario(body,linee) unless body.nil?
	out=out.gsub(/\s\s+/, "\s")
	guasto = false
	manutenzione = false
	maltempo = false
	a.categories.each do |c|
		if c.id == 101
			guasto = true
		end
		if c.id == 102
			manutenzione = true
		end
		if c.id == 103
			maltempo = true
		end		
	end

out_file.write a.id.to_s + "," + out + ",#{guasto},#{manutenzione},#{maltempo}\n"
    out_file.flush

end     


