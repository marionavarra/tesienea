#!/usr/bin/ruby2.3
require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'
require 'nokogiri'      #
require "./rimuovi_non_in_dizionario.rb"
require './modelli.rb'

file_dizionario = File.open("dizionario2.txt", "r")
linee =  file_dizionario.readlines
file_guasto = File.open("guasti_thread_#{ARGV[0]}_dizionario.txt","w")
file_maltempo = File.open("maltempo_thread_#{ARGV[0]}_dizionario.txt","w")
file_manutenzione = File.open("manutenzione_thread_#{ARGV[0]}_dizionario.txt","w")
file_idrico = File.open("idrico_thread_#{ARGV[0]}_dizionario.txt","w")
file_stradale = File.open("stradale_thread_#{ARGV[0]}_dizionario.txt","w")
file_telecomunicazioni = File.open("telecomunicazioni_thread_#{ARGV[0]}_dizionario.txt","w")
file_elettrico = File.open("elettrico_thread_#{ARGV[0]}_dizionario.txt","w")
alerts = Alert.all.limit(ARGV[2]).offset(ARGV[1])
alerts.each do |a|
    doc=a.title
	a.entries.each do |entry|
		doc+=entry.entry 
	end
    unless doc.nil?
		out=doc.gsub /^\s*$/m, ''                       # Remove carriage return
		out=out.gsub(/\s\s+/, "\s")  				#remove double space
		body=out.downcase.gsub(/\W+/, ' ')			#remove everything but the words
		#out_file.write "Da ripulire: " + body
    else
	   #out_file.write "documento non trovato"
	end
	#out_file.write "\nAlert Elaborato # " + a.id.to_s + " " + a.title
    #out_file.write "\nripulito # " + rimuovi_non_in_dizionario(body,linee) unless body.nil?
    #bodies.push + bodies.last
	out = rimuovi_non_in_dizionario(body,linee) unless body.nil?
	#out = lemmatizza_dizionario out
	out=out.gsub(/\s\s+/, "\s")
	guasto = false
	manutenzione = false
	maltempo = false
    idrico = false
    stradale = false        
    telecomunicazioni = false
    elettrico = false
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
    a.infrastructures.each do |i|
       if i.id == 48
           idrico = true
       end
       if i.id == 49
            stradale = true
       end
       if i.id == 50
          telecomunicazioni = true
       end
       if i.id == 51
           elettrico = true
       end
     end
     unless out==" "
     	file_guasto.write("#{a.id},#{out},#{guasto}\n")
	file_manutenzione.write("#{a.id},#{out},#{manutenzione}\n")
	file_maltempo.write("#{a.id},#{out},#{maltempo}\n")
    	file_idrico.write("#{a.id},#{out},#{idrico}\n")
	file_stradale.write("#{a.id},#{out},#{stradale}\n")
	file_telecomunicazioni.write("#{a.id},#{out},#{telecomunicazioni}\n")
	file_elettrico.write("#{a.id},#{out},#{elettrico}\n")
     end

    #out_file.flush

end     


