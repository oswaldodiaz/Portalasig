class CreateAdministrador < ActiveRecord::Migration
  def change
    create_table :administrador do |t|

      t.timestamps
    end
  end
end
