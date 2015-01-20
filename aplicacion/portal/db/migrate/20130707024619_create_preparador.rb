class CreatePreparador < ActiveRecord::Migration
  def change
    create_table :preparador do |t|

      t.timestamps
    end
  end
end
