ActiveRecord::Base.establish_connection(
  adapter:  'mysql2', # or 'postgresql' or 'sqlite3'
  database: 'navarra',
  username: 'dimartino',
  password: 'navarra',
  host:     'localhost',
  socket:   '/var/run/mysqld/mysqld.sock'
)
