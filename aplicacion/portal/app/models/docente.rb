class Docente < ActiveRecord::Base
	# attr_accessible :title, :body
	belongs_to :usuario, foreign_key: "id"
	has_many :docente_sitio_web, :dependent => :destroy

end
