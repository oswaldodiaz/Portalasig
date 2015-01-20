class Notice < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sitio_web
  belongs_to :usuario

  def noticia_corta
    return ((self.noticia.length <= 140)? self.noticia : self.noticia[0..140]+"...")
  end
end
