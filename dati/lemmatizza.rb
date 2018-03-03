def lemmatize text,linee
  text.split.each do |flessa|
  linee.each do |linea|
    lemmi = linea.split
      if lemmi[1] == flessa
        text = text.gsub(/\b#{flessa}\b/, lemmi[0])
        break
      end 
    end
  end
  text
end
