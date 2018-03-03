#!/usr/bin/ruby
require "./rimuovi_non_in_dizionario.rb"
file_test_input = File.open("test.txt", "r")
file_test_output = File.open("test_output.txt", "w")
file_dizionario = File.open("dizionario.txt", "r")
linee =  file_dizionario.readlines
doc = file_test_input.read
out=doc.gsub /^\s*$/m, ''                       # Remove carriage return
out=out.gsub(/\s\s+/, "\s")  				#remove double space
body=out.downcase.gsub(/\W+/, ' ')			#remove everything but the words
out = rimuovi_non_in_dizionario(body,linee) unless body.nil?
out=out.gsub(/\s\s+/, "\s")
file_test_output.write(out)

