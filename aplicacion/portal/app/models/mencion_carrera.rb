class MencionCarrera < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :mencion
  belongs_to :carrera
end
