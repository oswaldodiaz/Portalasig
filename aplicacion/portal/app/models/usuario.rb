# -*- encoding : utf-8 -*-
class Usuario < ActiveRecord::Base
	# attr_accessible :title, :body
	has_one :docente, foreign_key: "id", dependent: :destroy
	has_one :estudiante, foreign_key: "id", dependent: :destroy
	has_one :administrador, foreign_key: "id", dependent: :destroy

	has_many :comentario, :dependent => :destroy
	has_many :foro, :dependent => :destroy
	has_many :bitacora, :dependent => :destroy
	has_many :preparador, :through => :estudiante
	has_many :horario, :dependent => :destroy

	has_many :bitacora_sitio_web, :dependent => :destroy

	before_create :generar_clave
	after_create :enviar_correo_bienvenida
	before_save :arreglar_datos

	before_destroy :eliminar_sitios_web

	def eliminar_sitios_web
		SitioWeb.where(:usuario_id => self.id).each do |sitio_web|
			sitio_web.destroy
		end
	end

	def descripcion
    "#{self.cedula} - #{self.nombre_y_apellido}"
  end

	def generar_clave
		self.clave = SecureRandom.urlsafe_base64(32, false)
		self.activo = 0
	end

	def enviar_correo_bienvenida
		Mailer.registro_de_usuario(self)
	end

	def nombre_propio(array_nombres)
		nombres = ""
		array_nombres.split(" ").each_with_index do |nombre, index|
			aux = nombre.capitalize
			for j in 1..aux.length-1 do
				case aux[j]
				when "Á"
					aux[j] = "á"
				when "É"
					aux[j] = "é"
				when "Í"
					aux[j] = "í"
				when "Ó"
					aux[j] = "ó"
				when "Ú"
					aux[j] = "ú"
				when "Ñ"
					aux[j] = "ñ"
				end
			end
			nombres += ( (index == 0)? "" : " ") + aux
		end
		return nombres
	end

	def arreglar_datos
		self.nombre = nombre_propio(self.nombre)
		self.apellido = nombre_propio(self.apellido)
		self.correo = self.correo.downcase
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(64, false)
			break random_token unless Usuario.where(token: random_token).exists?
		end
	end	

	def self.autenticar(cedula, clave)
		if usuario = Usuario.where(:cedula => cedula, :clave => Digest::MD5.hexdigest(clave)).first
			if usuario.activo == 1
				return usuario
			else
				Mailer.notificar_usuario_no_activo(usuario)
			end
		end
		return nil
	end

	def self.validar_token(id,token)
		Usuario.where(:id => id, :token => token).first
	end

	def es_administrador?
		Administrador.where(:id => id).first
	end

	def es_docente?
		Docente.where(:id => id).first
	end

	def es_preparador?
		Preparador.where(:id => id).first
	end

	def es_estudiante?
		Estudiante.where(:id => id).first
	end

	def rol
		if ret = es_administrador?
			return ret
		end
		if ret = es_docente?
			return ret
		end
		if ret = es_preparador?
			return ret
		end
		if ret = es_estudiante?
			return ret
		end
	end

	def nombre_y_apellido
		if es_administrador?
			return "Administrador"
		end
		last_name = apellido.split(" ")[0]
		return nombre.split(" ")[0] + " " + last_name + ( (last_name.length < 4 && apellido.split(" ").length > 1)? (" "+apellido.split(" ")[1]) : "")
	end

	def tiene_mas_de_un_rol
		return ( ( (self.es_administrador? && self.es_estudiante?) || 
			(self.es_administrador? && self.es_docente?) || 
			(self.es_docente? && self.es_estudiante?) )? true : false)
	end

	def asignar_clave(clave)
		self.clave = Digest::MD5.hexdigest(clave)
	end

end
