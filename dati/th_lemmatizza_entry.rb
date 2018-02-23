#!/usr/bin/ruby
require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'
require 'nokogiri'      #
require "./rimuovi_non_in_dizionario.rb"
require './modelli.rb'
require "./lemmatizza.rb"
file_dizionario = File.open("lemmatization-it.txt", "r")
linee =  file_dizionario.readlines
#bodies = []
file_stop_words = File.open("stopwords.txt", "r")
stop_words_text = file_stop_words.read
stop_words = stop_words_text.split



file_guasto = File.open("guasti_thread_#{ARGV[0]}_dizionario.txt","w")
file_maltempo = File.open("maltempo_thread_#{ARGV[0]}_dizionario.txt","w")
file_manutenzione = File.open("manutenzione_thread_#{ARGV[0]}_dizionario.txt","w")
file_idrico = File.open("idrico_thread_#{ARGV[0]}_dizionario.txt","w")
file_stradale = File.open("stradale_thread_#{ARGV[0]}_dizionario.txt","w")
file_telecomunicazioni = File.open("telecomunicazioni_thread_#{ARGV[0]}_dizionario.txt","w")
file_elettrico = File.open("elettrico_thread_#{ARGV[0]}_dizionario.txt","w")
alerts = Alert.all.limit(ARGV[2]).offset(ARGV[1])
alerts.each do |a|
    	doc=a.title + " "
	a.entries.each do |entry|
		doc+=entry.entry 
	end
  
    #p "Documento da analizzare " + doc unless doc.nil?
	unless doc.nil?
		out=doc.gsub /^\s*$/m, ''                       # Remove carriage return
		out=out.gsub(/\s\s+/, "\s")  				#remove double space
		body=out.downcase.gsub(/\W+/, ' ')			#remove everything but the words
		body=body.gsub(/[^a-zA-Z ]/, '')			#remove everything but alphabetics
	else
	   #out_file.write "documento non trovato"
	end
	stop_words.each do |sw|
          body = body.gsub(/\b#{sw}\b/, '')
	end
	out = lemmatize(body,linee) unless body.nil?
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
end     


