class CreateMencion < ActiveRecord::Migration
  def change
    create_table :mencion do |t|

      t.timestamps
    end
  end
end
