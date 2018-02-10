require 'active_record'
require 'mysql2' # or 'pg' or 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2', # or 'postgresql' or 'sqlite3'
  database: 'info',
  username: 'root',
  password: 'stava',
  host:     'localhost',
  socket:   '/var/run/mysqld/mysqld.sock'
)
# Note that the corresponding table is 'orders'
class Alert < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_many :entries
end
class Category < ActiveRecord::Base
  has_and_belongs_to_many :alerts
end
class Entry < ActiveRecord::Base
  belongs_to :alert
end