def lemmatize text,linee
  
out_file = File.open("#{Time.now.strftime('%Y%m%d%H%M%S%L')}_Out_lemmatizza2.txt","w")


text.split.each do |flessa|
    out_file.write("Sto cercando: " + flessa)
    p "Sto cercando: " + flessa
      linee.each do |linea|
	lemmi = linea.split
	#p " 0 "+lemmi[0]	
	p "La cerco in " + lemmi[1]
      	if lemmi[1] == flessa
		p "trovata " + flessa + " sostituita con " + lemmi[0]
        	text = text.gsub(/\b#{flessa}\b/, lemmi[0])
        	break
        end 
    end
  end
out_file.flush
  text
end
