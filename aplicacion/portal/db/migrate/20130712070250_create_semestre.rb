class CreateSemestre < ActiveRecord::Migration
  def change
    create_table :semestre do |t|

      t.timestamps
    end
  end
end
