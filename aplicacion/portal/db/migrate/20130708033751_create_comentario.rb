class CreateComentario < ActiveRecord::Migration
  def change
    create_table :comentario do |t|

      t.timestamps
    end
  end
end
