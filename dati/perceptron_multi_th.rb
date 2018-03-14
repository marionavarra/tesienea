#!/usr/bin/ruby2.3
require 'date'
numthread=7
file = ["maltempo","manutenzione","guasto","telecomunicazioni","stradale","idrico","elettrico"]
th = []
alerts = []
count = 0
p DateTime.now.strftime("%d/%m/%Y %H:%M:%S")
numthread.times do |t|
  p "T " + t.to_s
  
    th[t]=Thread.new do
        p " TEST " 
        Thread.current["mycount"] = t
	p  " Thread Numero " + t.to_s 
	system "echo #{file[t]}>#{file[t]}_result.txt"
        system "spark-submit --class Perceptron /home/dimartino/Documenti/mario/codice/tesienea/perceptron/target/scala-2.11/perceptron_2.11-0.1.0-SNAPSHOT.jar #{file[t]} 2> #{file[t]}_error.txt >> #{file[t]}_result.txt"
	
      
	#  Thread.current["result"] = result
    end  
end

th.each {|t| t.join; print t["mycount"], "/tFinito #{DateTime.now.strftime("%d/%m/%Y %H:%M:%S")}/ " }
