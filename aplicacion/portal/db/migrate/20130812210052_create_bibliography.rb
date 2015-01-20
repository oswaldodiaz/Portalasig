class CreateBibliography < ActiveRecord::Migration
  def change
    create_table :bibliography do |t|

      t.timestamps
    end
  end
end
