class CreateClasificacion < ActiveRecord::Migration
  def change
    create_table :clasificacion do |t|

      t.timestamps
    end
  end
end
