class AddSessionsTable < ActiveRecord::Migration
  def change
    create_table :session do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :session, :session_id
    add_index :session, :updated_at
  end
end
