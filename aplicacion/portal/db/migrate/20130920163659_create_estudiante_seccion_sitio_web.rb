class CreateEstudianteSeccionSitioWeb < ActiveRecord::Migration
  def change
    create_table :estudiante_seccion_sitio_web do |t|

      t.timestamps
    end
  end
end
