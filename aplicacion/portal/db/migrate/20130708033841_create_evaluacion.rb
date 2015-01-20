class CreateEvaluacion < ActiveRecord::Migration
  def change
    create_table :evaluacion do |t|

      t.timestamps
    end
  end
end
