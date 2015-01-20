class Semestre < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :seccion, :dependent => :destroy
  has_many :sitio_web, :dependent => :destroy

  def self.semestre(periodo_academico,ano_lectivo)  
    if Semestre.where(:periodo_academico => periodo_academico, :ano_lectivo => ano_lectivo).size > 0
      return Semestre.where(:periodo_academico => periodo_academico, :ano_lectivo => ano_lectivo).first
    else
      semestre = Semestre.new
      semestre.periodo_academico = periodo_academico
      semestre.ano_lectivo = ano_lectivo
      semestre.save
      return semestre
    end
  end

  def periodo
    return "#{self.periodo_academico}-#{self.ano_lectivo}"
  end
end
