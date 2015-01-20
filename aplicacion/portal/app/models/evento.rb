class Evento < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sitio_web
  has_one :entrega, :dependent => :destroy

  def eliminar_evaluacion
    if evaluacion = Evaluacion.where(:evento_id => self.id).first
      evaluacion.destroy
    end
  end

  def guardar_evaluacion
    if evaluacion = Evaluacion.where(:evento_id => self.id).first
      evaluacion.nombre = self.titulo
      evaluacion.fecha_inicio = self.fecha_inicio
      evaluacion.fecha_fin = self.fecha_fin
      evaluacion.save

      self.evaluacion_id = evaluacion.id
      self.save
    end
  end

  def guardar_entrega
    if self.entrega
      if entrega.fecha_entrega != self.fecha_fin || entrega.nombre != self.titulo
        entrega.fecha_entrega = self.fecha_fin
        entrega.nombre = self.titulo
        entrega.save
      end
    end
  end
end
