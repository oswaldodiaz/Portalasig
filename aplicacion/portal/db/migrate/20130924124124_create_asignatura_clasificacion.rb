class CreateAsignaturaClasificacion < ActiveRecord::Migration
  def change
    create_table :asignatura_clasificacion do |t|

      t.timestamps
    end
  end
end
