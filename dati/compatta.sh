cat manutenzione_thread_* > manutenzione.csv
cat maltempo_thread_* > maltempo.csv
cat guasti_thread_* > guasto.csv
cat stradale_thread_* > stradale.csv
cat idrico_thread_* > idrico.csv
cat elettrico_thread_* > elettrico.csv
cat telecomunicazioni_thread_* > telecomunicazioni.csv
mv guasto.csv ../submit/
mv maltempo.csv ../submit/
mv manutenzione.csv ../submit/
mv elettrico.csv ../submit/
mv telecomunicazioni.csv ../submit/
mv stradale.csv ../submit/
mv idrico.csv ../submit/
