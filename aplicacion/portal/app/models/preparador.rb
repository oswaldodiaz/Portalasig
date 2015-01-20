class Preparador < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :estudiante
  belongs_to :sitio_web
  belongs_to :seccion

  before_create :asignar_correo

  before_save :crear_seccion

  after_destroy :eliminar_seccion

  def eliminar_seccion
    Seccion.all.each do |seccion|
      unless SeccionSitioWeb.where(:seccion_id => seccion.id).first
        seccion.destroy
      end
    end
  end

  def asignar_correo
    if self.correo == nil
      self.correo = self.estudiante.usuario.correo
    end
  end

  def crear_seccion
    if self.seccion_id != nil
      unless SeccionSitioWeb.where(:sitio_web_id => self.sitio_web_id, :seccion_id => self.seccion_id).size > 0
        seccion_sitio_web = SeccionSitioWeb.new
        seccion_sitio_web.sitio_web_id = self.sitio_web_id
        seccion_sitio_web.seccion_id = self.seccion_id
        seccion_sitio_web.save
      end
    end
  end

  def seccion_nombre
    if self.seccion_id != nil
      return self.seccion.nombre
    end
    return ""
  end
end
