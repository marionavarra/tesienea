class CreateClassifications < ActiveRecord::Migration
  def change
    create_table :classifications do |t|
      t.text :notizia
      t.boolean :maltempo
      t.boolean :manutenzione
      t.boolean :guasto
      t.boolean :idrica
      t.boolean :stradale
      t.boolean :telecomunicazioni
      t.boolean :elettrica

      t.timestamps null: false
    end
  end
end
