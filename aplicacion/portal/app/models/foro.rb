class Foro < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sitio_web
  belongs_to :usuario
  has_many :comentario, :dependent => :destroy

  def descripcion_corta
    return ((self.descripcion.length <= 140)? self.descripcion : self.descripcion[0..140]+"...")
  end

end
