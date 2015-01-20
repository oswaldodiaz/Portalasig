class CreateObjetivo < ActiveRecord::Migration
  def change
    create_table :objetivo do |t|

      t.timestamps
    end
  end
end
