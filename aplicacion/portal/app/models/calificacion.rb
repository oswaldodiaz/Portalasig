class Calificacion < ActiveRecord::Base
  # attr_accessible :title, :
  belongs_to :evaluacion
  belongs_to :estudiante
end
