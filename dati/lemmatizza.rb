def lemmatize text,linee
  


text.split.each do |flessa|
    #p "Sto cercando: " + flessa
      linee.each do |linea|
	lemmi = linea.split
	#p " 0 "+lemmi[0]	
	#p "La cerco in " + lemmi[1]
      	if lemmi[1] == flessa
		p "trovata " + flessa + " sostituita con " + lemmi[0]
        	text = text.gsub(/\b#{flessa}\b/, lemmi[0])
        	break
        end 
    end
  end
  text
end
