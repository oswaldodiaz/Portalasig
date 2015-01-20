class CreateDocente < ActiveRecord::Migration
  def change
    create_table :docente do |t|

      t.timestamps
    end
  end
end
