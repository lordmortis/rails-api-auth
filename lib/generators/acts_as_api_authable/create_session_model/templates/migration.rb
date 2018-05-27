class Create_CamelName_ < ActiveRecord::Migration[_RAILS_VERSION_]
  def change
    create_table :_snake_case_, id: false do |t|
      t.uuid :id, primary_key: true, null: false
      t.integer :authable_id
      t.string :authable_type
      t.string :device_name
      t.boolean :http_only, null: false
      t.binary :secret, null: false
      t.datetime :expires_at, null: false
      t.timestamps null: false
    end
    add_index :_snake_case_, [:authable_type, :authable_id]
  end
end
