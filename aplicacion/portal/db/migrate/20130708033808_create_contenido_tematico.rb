class CreateContenidoTematico < ActiveRecord::Migration
  def change
    create_table :contenido_tematico do |t|

      t.timestamps
    end
  end
end
