class CreateEntregable < ActiveRecord::Migration
  def change
    create_table :entregable do |t|

      t.timestamps
    end
  end
end
