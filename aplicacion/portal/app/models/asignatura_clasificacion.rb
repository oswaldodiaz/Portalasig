class AsignaturaClasificacion < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :asignatura
  belongs_to :clasificacion
end
