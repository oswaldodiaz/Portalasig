class SeccionSitioWeb < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :seccion
  belongs_to :sitio_web

  has_many :estudiante_seccion_sitio_web, :dependent => :destroy

  def estudiantes
    Usuario.order("cedula").where(:id => EstudianteSeccionSitioWeb.where(:seccion_sitio_web_id => self.id).collect{|x| x.estudiante_id})
  end

  def correos
    correo =""
    self.estudiantes.each_with_index do |estudiante, index|
      correo += ((index==0)? "" : ";") + estudiante.correo
    end
    return correo

  end

end
