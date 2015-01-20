class Seccion < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :periodo
  belongs_to :asignatura
  
  has_many :preparador, :dependent => :destroy
  has_many :docente_sitio_web, :dependent => :destroy
  has_many :seccion_sitio_web, :dependent => :destroy
  has_many :horario, :dependent => :destroy

  def self.destroy_seccion_sitio_web(seccion_id,sitio_web_id)
    sitio_web = SitioWeb.find(sitio_web_id)
    seccion = Seccion.find(seccion_id)
    
    if seccion_sitio_web = SeccionSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web_id).first
      DocenteSitioWeb.where(:seccion_id => seccion.id, :sitio_web_id => sitio_web_id).each do |docente_sitio_web|
        docente_sitio_web.seccion_id = nil
        docente_sitio_web.save
      end

      Preparador.where(:seccion_id => seccion.id, :sitio_web_id => sitio_web_id).each do |preparador|
        preparador.seccion_id = nil
        preparador.save
      end

      Horario.where(:seccion_id => seccion.id, :sitio_web_id => sitio_web_id).each do |horario|
        horario.seccion_id = nil
        horario.save
      end

      EstudianteSeccionSitioWeb.where(:seccion_sitio_web_id => seccion_sitio_web.id).each do |estudiante_seccion_sitio_web|
        estudiante_seccion_sitio_web.destroy
      end

      seccion_sitio_web.destroy

      unless SeccionSitioWeb.where(:seccion_id => seccion.id).size > 0
        seccion.destroy
      end
    end
  end

end
