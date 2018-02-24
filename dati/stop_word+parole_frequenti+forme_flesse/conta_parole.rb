files = ["maltempo","manutenzione","guasto","telecomunicazioni","stradale","idrico","elettrico"]
files.each do |file|
 current_r = File.open("#{file}.csv","r")
 current_w = File.open("#{file}.txt","w")
 linee = current_r.readlines
 linee.each do |linea|
  unless linea.split(",")[1].size < 31
   current_w.write(linea)
  end
 end  
end
