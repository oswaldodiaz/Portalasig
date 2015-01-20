#encoding: utf-8
class Asignatura < ActiveRecord::Base
	# attr_accessible :title, :body
	has_many :sitio_web, :dependent => :destroy

	has_many :asignatura_carrera, :dependent => :destroy
	has_one :asignatura_clasificacion, :dependent => :destroy
	has_many :asignatura_mencion, :dependent => :destroy
	
	before_save :arreglar_datos

  after_destroy :eliminar_datos

  def eliminar_datos
    
    Clasificacion.all().each do |clasificacion|
      unless AsignaturaClasificacion.where(:clasificacion_id => clasificacion.id).size > 0
        clasificacion.destroy
      end
    end

    
    Mencion.all().each do |mencion|
      unless AsignaturaMencion.where(:mencion_id => mencion.id).size > 0
        mencion.destroy
      end
    end

  end

	def tiene_sitio_web?
		return ( (SitioWeb.where(:asignatura_id => id).size > 0)? true : false )
	end

	def ultimo_sitio_web
		SitioWeb.order("created_at desc").where(:asignatura_id => id).first
	end

  def tiene_varios_sitios_web
    return ( (SitioWeb.where(:asignatura_id => id).size > 1)? true : false )
  end

	def arreglar_datos
    if self.nombre
  		nombres = ""
  		self.nombre.split(" ").each_with_index do |palabra, index|
  			case palabra.downcase
  			when "i"
  			palabra = "I"
  			when "ii"
  			palabra = "II"
  			when "iii"
  			palabra = "III"
  			when "iv"
  			palabra = "IV"
  			when "v"
  			palabra = "V"
  			when "vi"
  			palabra = "VI"
  			when "vii"
  			palabra = "VII"
  			when "viii"
  			palabra = "VIII"
  			when "ix"
  			palabra = "IX"
  			when "x"
  			palabra = "X"
  			else
  				if palabra.length == 1
  					palabra = palabra.downcase
  				else
  					letras = palabra.capitalize
  					palabra = ""
  					letras.split("").each_with_index do |letra, index|
  						case letra
  						when "Á"
  							letra = "á"
  						when "É"
  							letra = "é"
  						when "Í"
  							letra = "í"
  						when "Ó"
  							letra = "ó"
  						when "Ú"
  							letra = "ú"
  						when "Ñ"
  							letra = "ñ"
  						end
  						palabra += letra
  					end
  				end
  			end
  			nombres += ( (index == 0)? "" : " ") + palabra
  		end

  		self.nombre = nombres
    end

    unless self.requisitos
      self.requisitos = "Ninguno"
    end
	end	

	def nombre_url
    nombre_url = ""
    self.nombre.downcase.split(" ").each_with_index do |nombre,index|
      nombre_url << ((index == 0)? "": "_") + nombre
    end

    return nombre_url
  end

  def se_puede_crear_sitio_web?
    fecha = Time.now
		periodo_academico = ( (fecha.month < 7)? "I" : "II" )
		ano_lectivo = fecha.year
		
		semestre_siguiente = ( (periodo_academico == "I")? ("II" + "-" + ano_lectivo.to_s ) : ("I" + "-" + (ano_lectivo+1).to_s) )

		unless semestre = Semestre.where(:periodo_academico => semestre_siguiente.split("-")[0], :ano_lectivo => semestre_siguiente.split("-")[1]).first
			semestre = Semestre.new
			semestre.periodo_academico = semestre_siguiente.split("-")[0]
			semestre.ano_lectivo = semestre_siguiente.split("-")[0]
			semestre.save
		end

		return ( (SitioWeb.where(:asignatura_id => self.id, :semestre_id => semestre.id).first)? false : true )
  end

  def numero_menciones
  	return self.asignatura_mencion.size
  end

  def menciones_arregladas
  	menciones = ""
  	self.asignatura_mencion.each_with_index do |asignatura_mencion, i|
  		if i == 0
  			menciones += asignatura_mencion.mencion.nombre
  		elsif i == self.asignatura_mencion.size-1
  			menciones += " y " + asignatura_mencion.mencion.nombre
  		else
  			menciones += ", " + asignatura_mencion.mencion.nombre
  		end
  	end
  	return menciones
  end

  def carreras_arregladas
    carreras = ""
    self.asignatura_carrera.each_with_index do |asignatura_carrera, i|
      if i == 0
        carreras += asignatura_carrera.carrera.nombre
      elsif i == self.asignatura_carrera.size-1
        carreras += " y " + asignatura_carrera.carrera.nombre
      else
        carreras += ", " + asignatura_carrera.carrera.nombre
      end
    end
    return carreras
  end
end
