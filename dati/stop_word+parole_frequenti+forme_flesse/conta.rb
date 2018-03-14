files = ["maltempo","manutenzione","guasto","telecomunicazioni","stradale","idrico","elettrico"]
files.each do |file|
 current_r = File.open("#{file}.csv","r")
 #current_w = File.open("#{file}.txt","w")
 linee = current_r.readlines
 p file 
 linee.each do |linea|
  if linea.split(",")[1].split.size <11
   p linea.split(",")[1].size.to_s + " " + linea.split(",")[1]
  end
 end  
end
