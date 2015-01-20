class CreateCalificacion < ActiveRecord::Migration
  def change
    create_table :calificacion do |t|

      t.timestamps
    end
  end
end
