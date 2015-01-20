class CreateHorario < ActiveRecord::Migration
  def change
    create_table :horario do |t|

      t.timestamps
    end
  end
end
