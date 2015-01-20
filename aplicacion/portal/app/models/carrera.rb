class Carrera < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :asignatura, :dependent => :destroy
  has_many :sitio_web, :through => :asignatura
  has_many :mencion
  has_many :mencion_carrera, :dependent => :destroy

  def tiene_sitios_web?
  	return ( (self.sitio_web.size > 0)? true : false)
  end

  def asignaturas_ordenadas_por_clasificacion
  	return self.asignatura.order("mencion_id")
  end

  def tiene_asignaturas_obligatorias?
    return Asignatura.where(:tipo => "Obligatoria", :id => AsignaturaCarrera.where(:carrera_id => self.id).collect{ |x| x.asignatura_id}).size > 0
  end

  def tiene_asignaturas_electivas?
    return Asignatura.where(:tipo => ["Electiva","Obligatoria optativa"], :id => AsignaturaCarrera.where(:carrera_id => self.id).collect{ |x| x.asignatura_id}).size > 0
  end

  def tiene_asignaturas_otras?
    return self.asignaturas_tipo_otra.size > 0
  end

  def asignaturas_tipo_otra
    return Asignatura.where(:tipo => ["Otra"], :id => AsignaturaCarrera.where(:carrera_id => self.id).collect{ |x| x.asignatura_id})
  end
end
