class Comentario < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :foro
  belongs_to :usuario
end
