class CreateUsuario < ActiveRecord::Migration
  def change
    create_table :usuario do |t|

      t.timestamps
    end
  end
end
