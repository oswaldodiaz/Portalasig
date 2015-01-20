class Mencion < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :carrera

  has_many :asignatura_mencion, :dependent => :destroy
  has_many :mencion_carrera, :dependent => :destroy

  def tiene_asignaturas_con_sitio_web?
  	return ( (SitioWeb.where(:asignatura_id => Asignatura.where(:mencion_id => self.id).collect{|x| x.id}).size > 0)? true : false)
  end

  def es_semestre?
    return ((self.nombre.downcase =~ /semestre(.*)/)? true : false)
  end
end
