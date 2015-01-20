class Entrega < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :sitio_web
  belongs_to :evento

  has_many :entregable, :dependent => :destroy

  before_save :guardar_evento

  def finalizo?
    f = self.fecha_entrega.strftime("%d/%m/%Y").split("/")
    hoy = Time.now
    f2 = hoy.strftime("%d/%m/%Y").split("/")
    return DateTime.new(f[2].to_i, f[1].to_i, f[0].to_i, 23, 59, 59) < DateTime.new(f2[2].to_i, f2[1].to_i, f2[0].to_i, 23, 59, 59)
  end

  def tiene_entregables?
    return self.entregable.size > 0
  end

  def ruta      
    ruta = Rails.root.join('doc/'+sitio_web.nombre_url+"/"+sitio_web.periodo,'entregas').to_s
    return ruta
  end

  def guardar_evento
    if self.evento_id == nil
      evento = Evento.new
      evento.sitio_web_id = self.sitio_web_id
      evento.titulo = self.nombre
      evento.descripcion = self.nombre
      evento.fecha_inicio = self.fecha_entrega
      evento.fecha_fin = self.fecha_entrega
      evento.save

      self.evento_id = evento.id
    else
      evento = Evento.find(self.evento_id)
      if evento.titulo != self.nombre || evento.fecha_fin != self.fecha_entrega
        evento.titulo = self.nombre
        evento.descripcion = self.nombre
        evento.fecha_inicio = self.fecha_entrega
        evento.fecha_fin = self.fecha_entrega
        evento.save
      end
    end
  end
end
