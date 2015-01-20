class CreateCarrera < ActiveRecord::Migration
  def change
    create_table :carrera do |t|

      t.timestamps
    end
  end
end
