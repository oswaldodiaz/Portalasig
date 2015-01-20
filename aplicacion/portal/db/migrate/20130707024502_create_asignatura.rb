class CreateAsignatura < ActiveRecord::Migration
  def change
    create_table :asignatura do |t|

      t.timestamps
    end
  end
end
