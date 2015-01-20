class CreateAsignaturaCarrera < ActiveRecord::Migration
  def change
    create_table :asignatura_carrera do |t|

      t.timestamps
    end
  end
end
