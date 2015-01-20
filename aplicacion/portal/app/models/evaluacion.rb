class Evaluacion < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sitio_web
  has_many :calificacion, :dependent => :destroy

  def eliminar_evento
    if evento = Evento.where(:evaluacion_id => self.id).first
      evento.destroy
    end
  end

  def guardar_evento
    if self.fecha_inicio == nil
      if evento = Evento.where(:evaluacion_id => self.id).first
        evento.destroy

        self.evento_id = nil
        self.save
      end
    
    else
      unless evento = Evento.where(:evaluacion_id => self.id).first
        evento = Evento.new
        evento.evaluacion_id = self.id
        evento.sitio_web_id = self.sitio_web_id
      end
      evento.titulo = self.nombre
      evento.descripcion = self.nombre
      evento.fecha_inicio = self.fecha_inicio
      if self.fecha_fin != nil
        evento.fecha_fin = self.fecha_fin
      else
        evento.fecha_fin = self.fecha_inicio
      end

      evento.save

      self.evento_id = evento.id
      self.save
    end
  end
end
