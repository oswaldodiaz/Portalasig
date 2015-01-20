class AsignaturaMencion < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :asignatura
  belongs_to :mencion
end
