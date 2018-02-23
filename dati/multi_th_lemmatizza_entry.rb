#!/usr/bin/ruby
require 'thread'
require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'
require './modelli.rb'
numthread=16
tot = Alert.all.count
p "total alerts: " + tot.to_s
per_thread = tot / numthread
#per_thread = 10
p "alerts per thread " + per_thread.to_s
th = []
alerts = []
count = 0
numthread.times do |t|
  p "T " + t.to_s
  if t == 0
    
    th[t]=Thread.new do
        p " TEST " 
        Thread.current["mycount"] = t
	p  " Thread Numero " + t.to_s 
	p "# da analizzare " + per_thread.to_s
	
      result = `./th_lemmatizza_entry.rb 0 0 #{per_thread}` 
	#  Thread.current["result"] = result
    end
  else
    th[t]=Thread.new do
      p " Thread Numero " + t.to_s
	  p "# da analizzare " + per_thread.to_s
      Thread.current["mycount"] = t
	  result = `./th_lemmatizza_entry.rb #{t} #{per_thread*t} #{per_thread}`
      #Thread.current["result"] = result
	end
  end
end

th.each {|t| t.join; print t["mycount"], ", " }
