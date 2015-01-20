class CreateNotice < ActiveRecord::Migration
  def change
    create_table :notice do |t|

      t.timestamps
    end
  end
end
