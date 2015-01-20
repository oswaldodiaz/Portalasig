class BitacoraSitioWeb < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :usuario
  belongs_to :sitio_web
end
