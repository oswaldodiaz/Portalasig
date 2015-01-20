class EstudianteSeccionSitioWeb < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :estudiante
  belongs_to :seccion_sitio_web
end
