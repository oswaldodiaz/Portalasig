class Administrador < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :usuario
end