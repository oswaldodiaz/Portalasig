class Clasificacion < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :asignatura_clasificacion, :dependent => :destroy
end
