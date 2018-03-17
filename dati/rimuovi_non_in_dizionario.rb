def rimuovi_non_in_dizionario text,dizionario
  text.split.each do |p_text|
    trovata = false
	lemma = ""
    dizionario.each do |linea|
      p_diz = linea.split[0]
	  lemma = linea.split[1]
      if p_text == p_diz
        trovata=true
		text = text.gsub(/\b#{p_text}\b/, lemma)#	unless text.nil?  
        break
      end 
    end
    unless trovata
      text = text.gsub(/\b#{p_text}\b/, '')	  
    end 
  end
  text
end

def lemmatizza_dizionario text, dizionario
  text.split.each do |p_text|
	dizionario.each do |linea|
   
	end
	p "PAROLA Trovata #{p_diz}"
		p "Da lemmitizzare con #{lemma}"
  end	
end
