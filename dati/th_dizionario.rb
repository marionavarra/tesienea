#!/usr/bin/ruby
require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'
require 'nokogiri'      #
require "./rimuovi_non_in_dizionario.rb"
require './modelli.rb'

file_dizionario = File.open("dizionario.txt", "r")
linee =  file_dizionario.readlines
#bodies = []
file_guasto = File.open("guasti_thread_#{ARGV[0]}_dizionario.txt","w")
file_maltempo = File.open("maltempo_thread_#{ARGV[0]}_dizionario.txt","w")
file_manutenzione = File.open("manutenzione_thread_#{ARGV[0]}_dizionario.txt","w")
#out_file = File.open("#{Time.now.strftime('%Y%m%d%H%M%S%L')}_Out_th_dizionario.txt","w")
#out_file.write "id,text,guasto,manutenzione,maltempo\n"#
alerts = Alert.all.limit(ARGV[2]).offset(ARGV[1])
alerts.each do |a|
    doc=a.title
	a.entries.each do |entry|
		doc+=entry.entry 
	end
  
    #p "Documento da analizzare " + doc unless doc.nil?
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

   #out_file.write a.id.to_s + "," + out + ",#{guasto},#{manutenzione},#{maltempo}\n"
    file_guasto.write("#{a.id},#{out},  #{guasto}\n")
	file_manutenzione.write("#{a.id},#{out},#{manutenzione}\n")
	file_maltempo.write("#{a.id},#{out},#{maltempo}\n")


    #out_file.flush

end     


