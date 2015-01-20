class Estudiante < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :usuario, foreign_key: "id"
  has_many :preparador, :dependent => :destroy
  has_many :estudiante_seccion_sitio_web, :dependent => :destroy

  has_many :entregable, :dependent => :destroy

  has_many :calificacion, :dependent => :destroy
end
