class CreateSeccion < ActiveRecord::Migration
  def change
    create_table :seccion do |t|

      t.timestamps
    end
  end
end
