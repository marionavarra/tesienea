def rimuovi_non_in_dizionario text,dizionario
	#out_file = File.open("#{Time.now.strftime('%Y%m%d%H%M%S%L')}_Out_rimuovi_non_in_dizionario.txt","w")
	text.split.each do |p_text|
	trovata = false
    #p "Sto cercando: " + flessa
  dizionario.each do |linea|
	p_diz = linea.split[0]
	#p " 0 "+lemmi[0]	
	#p "La cerco in " + lemmi[1]
	#out_file.write "cerco la parola " +  p_diz
      	if p_text == p_diz
		#out_file.write "\ntrovata " + p_text 
        	trovata=true
        	break
        end 
   end
   unless trovata
     #out_file.write "non presente in dizionario " + p_text + " elimino\n"
     text = text.gsub(/\b#{p_text}\b/, '')
   end 
 end
  text
end
