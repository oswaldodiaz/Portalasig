class CreateMencionCarrera < ActiveRecord::Migration
  def change
    create_table :mencion_carrera do |t|

      t.timestamps
    end
  end
end
