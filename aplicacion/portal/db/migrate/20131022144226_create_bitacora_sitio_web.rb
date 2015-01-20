class CreateBitacoraSitioWeb < ActiveRecord::Migration
  def change
    create_table :bitacora_sitio_web do |t|

      t.timestamps
    end
  end
end
