class CreateDocenteSitioWeb < ActiveRecord::Migration
  def change
    create_table :docente_sitio_web do |t|

      t.timestamps
    end
  end
end
