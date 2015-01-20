class CreateEvento < ActiveRecord::Migration
  def change
    create_table :evento do |t|

      t.timestamps
    end
  end
end
