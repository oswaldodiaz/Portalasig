class CreateBitacora < ActiveRecord::Migration
  def change
    create_table :bitacora do |t|

      t.timestamps
    end
  end
end
