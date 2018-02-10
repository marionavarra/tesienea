#!/usr/bin/ruby
require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'
require 'nokogiri'      #


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
file_stop_words = File.open("stopwords.txt", "r")
file_guasto = File.open("guasto.csv", "w")
file_manutenzione = File.open("manutenzione.csv", "w")
file_maltempo = File.open("maltempo.csv", "w")
stop_words_text = file_stop_words.read
stop_words = stop_words_text.split
	
Alert.all.each do |a|
	p "Inizio Elaborazione # " + a.id.to_s + " " + a.title	
	doc = a.description
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
	title = a.title.downcase.gsub /\W+/, ' '
	p "Stop Words # " + a.id.to_s	
	stop_words.each do |sw|
	  body = body.gsub(/\b#{sw}\b/, '')
	  title = title.gsub(/\b#{sw}\b/, '')
	end
	#p "____________________ PRIMA _______________"
	#p body
	#p "____________________ DOPO _______________"	
	#p body
	
        file_guasto.write("#{a.id}, #{body} #{title},  #{guasto}\n")
	file_manutenzione.write("#{a.id}, #{body} #{title},  #{manutenzione}\n")
	file_maltempo.write("#{a.id}, #{body} #{title},  #{maltempo}\n")
	#p "Categorie: "  +  categorie
	#p "Titolo: " + a.title	
	 # puts "alert: #{a.html.gsub(/(\<.+\>)/, "")}"
	#p "#############################################"
end

	

#p Category.all
