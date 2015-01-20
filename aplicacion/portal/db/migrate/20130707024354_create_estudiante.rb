class CreateEstudiante < ActiveRecord::Migration
  def change
    create_table :estudiante do |t|

      t.timestamps
    end
  end
end
