file_guasto = File.open("manutenzione.csv","r")
id_corti = File.open("id_da_greppare.txt","w")
 = File.open("id_da_greppare.txt","w")
linee = file_guasto.readlines
linee.each do |linea|
  parole = linea.split(",")[1].size.to_s
  if linea.split(",")[1].size < 31
     id_corti.write(linea.split(",")[0].to_s+"\n")
  end
end  
