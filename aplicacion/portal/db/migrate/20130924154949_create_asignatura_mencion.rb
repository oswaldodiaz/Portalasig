class CreateAsignaturaMencion < ActiveRecord::Migration
  def change
    create_table :asignatura_mencion do |t|

      t.timestamps
    end
  end
end
