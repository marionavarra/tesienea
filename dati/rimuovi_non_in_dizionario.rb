def rimuovi_non_in_dizionario text,dizionario
  text.split.each do |p_text|
    trovata = false
    dizionario.each do |linea|
      p_diz = linea.split[0]
      if p_text == p_diz
        trovata=true
        break
      end 
    end
    unless trovata
      text = text.gsub(/\b#{p_text}\b/, '')
    end 
  end
  text
end
