class CreateSitioWeb < ActiveRecord::Migration
  def change
    create_table :sitio_web do |t|

      t.timestamps
    end
  end
end
