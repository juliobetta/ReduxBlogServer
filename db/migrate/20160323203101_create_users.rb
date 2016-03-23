class CreateUsers < ActiveRecord::Migration
  def change
    drop_table :users if ActiveRecord::Base.connection.table_exists? :users
    create_table :users do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
