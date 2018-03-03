file_dizionario_originale = File.open("dizionario_originale.txt", "r")
file_dizionario = File.open("dizionario.txt", "w")
file_lemmi = File.open("lemmatization-it.txt", "r")
linee_dizionario = file_dizionario_originale.readlines
linee_lemmi = file_lemmi.readlines
linee_dizionario.each do |word_old|
  file_dizionario.write word_old.split[0] + "\n"
  file_dizionario.flush
  linee_lemmi.each do |linea|
    if linea.split[0]==word_old.split[0]
      file_dizionario.write linea.split[1] + "\n"
      file_dizionario.flush
      p "Aggiunta #{linea.split[1]} al dizionario"
    end
  end
end

