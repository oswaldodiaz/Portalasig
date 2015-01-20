class Bibliography < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sitio_web
end
