class CreateArchivo < ActiveRecord::Migration
  def change
    create_table :archivo do |t|

      t.timestamps
    end
  end
end
