class CreateSeccionSitioWeb < ActiveRecord::Migration
  def change
    create_table :seccion_sitio_web do |t|

      t.timestamps
    end
  end
end
