class Horario < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sitio_web
  belongs_to :seccion
  belongs_to :usuario

  def docente_sitio_web
    DocenteSitioWeb.where(:docente_id => self.usuario_id, :sitio_web_id => self.sitio_web_id).first
  end

  def preparador
    Preparador.where(:estudiante_id => self.usuario_id, :sitio_web_id => self.sitio_web_id).first
  end
end
