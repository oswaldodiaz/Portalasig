class CreateForo < ActiveRecord::Migration
  def change
    create_table :foro do |t|

      t.timestamps
    end
  end
end
