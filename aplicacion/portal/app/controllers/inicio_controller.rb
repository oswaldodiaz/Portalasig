# -*- encoding : utf-8 -*-
class InicioController < ApplicationController
	layout "inicio"

	before_filter :es_ajax?, :only => [:iniciar_sesion, :activar_usuario, :enviar_correo_olvido_clave, :recuperar_clave, :procesar_cambiar_clave, :procesar_agregar_asignatura]

	#Vista index
	def index
		@clasificaciones = ["Semestre I", "Semestre II", "Semestre III", "Semestre IV", "Semestre V", 
												"Semestre VI", "Semestre VII", "Semestre VIII", "Semestre IX", "Semestre X"]
		
		@carrera = params[:id] if params[:id]
		@asignatura_datos = [] #En este arreglo se guardan los pares "Codigo - Nombre" de cada asignatura para mostrar en el campo de busqueda
		Asignatura.order('nombre').all.each do |asignatura|
			#En este foro se agregan uno a uno los valores de cada asignatura al arreglo de la manera indicada arriba
			@asignatura_datos << asignatura.codigo.to_s + " - " + asignatura.nombre.to_s
		end
	end
	
	#Vista créditos
	def creditos
		@titulo = "Créditos"
	end
	
	#Método para inicio de sesión, se accede a este a través de AJAX
	def iniciar_sesion
		cedula = params[:cedula]
		clave = params[:clave]
		errores = ""
		success = ""
		reset_session
		if cedula && clave
			if usuario = Usuario.autenticar(cedula,clave)
				if usuario.activo == 1
					session[:usuario] = usuario
					session[:rol] = usuario.rol
					success = "ok"
					bitacora "El usuario #{usuario.descripcion} inició sesion"
				else
					Mailer.notificar_usuario_no_activo(usuario)
				end
			end			
		end

		if success == "ok"
			if session[:usuario].es_administrador?
				render :json => JSON.parse('{"success":"ok","admin":"true" }')
			else
				render :json => JSON.parse('{"success":"ok","admin":"false" }')
			end

			flash[:exito] = "Inicio de sesión exitoso"
		else
			errores = '{"error": "La cédula y/o clave es incorrecta. Inténtelo nuevamente."}'
			bitacora "Intento fallido de inicio de sesion con cédula #{cedula} y clave #{clave}"
			render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
		end
	end

	#Método para cerrar la sesión del usuario
	def cerrar_sesion
		admin = session[:usuario].es_administrador? if session[:usuario]
		bitacora "El usuario #{session[:usuario].descripcion} ha cerrado sesión" if session[:usuario]
		reset_session
		flash[:mensaje] = "Su sesión ha sido cerrada exitosamente."

		if admin
			redirect_to :action => "index", :controller => "inicio"
		else
			redirect_to :back
		end
	end

	#Vista para el ingreso al sistema
	def ingreso
		@titulo = "Ingreso al portal"
		reset_session
		if params[:id] && params[:token]
			id = params[:id]
			token = params[:token]
			if __es_numero_entero?(id) && __es_token?(token)
				if @usuario = Usuario.validar_token(id,token)
					if @usuario.activo == 0
						bitacora "Ingreso correcto al sistema para el usuario con id #{params[:id]} y token #{params[:token]}"
						return
					else
						flash[:error] = "Disculpe, pero su usuario ya se encuentra activo."
					end
				end
			end
		end

		bitacora "Intento fallido de ingreso al sistema con id #{params[:id]} y token #{params[:token]}"
		redirect_to :action => "index", :controller => "inicio"
	end

	#Método para la activacion del usuario ingresando su clave al sistema por primera vez
	def activar_usuario
		errores = ""
		success = ""
		if params[:id] && params[:token] && params[:clave] && params[:confirmacion]
			id = params[:id]
			token = params[:token]
			clave = params[:clave]
			confirmacion = params[:confirmacion]
			

			if usuario = Usuario.where(:id => id, :token => token).first
				if usuario.activo == 0
					if clave == confirmacion
						usuario.activo = 1
						usuario.asignar_clave(clave)
						if usuario.save
							Mailer.notificar_usuario_activo(usuario)

							session[:usuario] = usuario
							session[:rol] = usuario.rol
							bitacora "El usuario #{usuario.descripcion} inició sesion"
							
							success = "ok"
							flash[:exito] = "Se activó su cuenta satisfactoriamente."
							bitacora "Se activó el usuario #{usuario.descripcion}"
						else
							errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero no se pudo guardar su clave. Inténtelo nuevamente."}'
						end
					else
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Las claves no coinciden. Inténtelo nuevamente."}'
					end
				else
					errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero su usuario ya se encuentra activo."}'
				end
			end
		end

		if success == "ok"
			render :json => JSON.parse('{"success":"ok"}')
		else
			bitacora "Intento fallido de activación de usuario con id #{params[:id]}, token #{params[:token]}, clave #{params[:clave]} y confirmacion #{params[:confirmacion]}"
			render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
		end
	end

	def olvido_clave
		@titulo = "¿Olvidó su clave?"
		reset_session
	end
	
	def enviar_correo_olvido_clave
		reset_session
		errores = ""
		success = ""
		if params[:cedula]
			cedula = params[:cedula]
			if __es_numero_entero?(cedula)
				if usuario = Usuario.where(:cedula => cedula).first
					if usuario.activo == 1
						Mailer.notificar_solicitud_cambio_de_clave(usuario)
						success = "ok"
						flash[:exito] = "Se le envió un correo para que recupere su clave."
						bitacora "Se envió un correo al usuario #{usuario.descripcion} para que recupere su clave."
					else
						Mailer.notificar_usuario_no_activo(usuario)
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Su usuario no se encuentra activo, se le ha enviado un correo para que pueda activarlo."}'
					end						
				else
					errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El número de cédula insertado no existe en el sistema."}'
				end
			else
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El número de cédula insertado es incorrecto."}'
			end
		else
			errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se pudo enviar el correo."}'
		end

		
		if success == "ok"
			render :json => JSON.parse('{"success":"ok"}')
		else
			bitacora "Intento fallido de activación de usuario con id #{params[:id]}, token #{params[:token]}, clave #{params[:clave]} y confirmacion #{params[:confirmacion]}"
			render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
		end
	end

	def cambio_de_clave
		@titulo = "Cambio de clave"
		if params[:id] && params[:token]
			id = params[:id]
			token = params[:token]
			if __es_numero_entero?(id) && __es_token?(token)
				if @usuario = Usuario.validar_token(id,token)
					if @usuario.activo == 1
						bitacora "Ingreso a cambio de clave correcto para el usuario con id #{params[:id]} y token #{params[:token]}"
						return
					else
						flash[:error] = "Disculpe, pero su usuario no se encuentra activo."
					end
				end
			end
		end

		bitacora "Intento fallido de ingreso a cambio de clave con id #{params[:id]} y token #{params[:token]}"
		redirect_to :action => "index", :controller => "inicio"
	end

	#Método para recuperar la clave al olvidarla
	def recuperar_clave
		errores = ""
		success = ""
		if params[:id] && params[:token] && params[:clave_nueva] && params[:confirmacion]
			id = params[:id]
			token = params[:token]
			clave_nueva = params[:clave_nueva]
			confirmacion = params[:confirmacion]
	
			if usuario = Usuario.validar_token(id,token)
				if usuario.activo == 1
					if clave_nueva == confirmacion && clave_nueva != ""
						usuario.asignar_clave(clave_nueva)
						if usuario.save
							Mailer.notificar_cambio_de_clave_exitoso(usuario)
							
							session[:usuario] = usuario
							session[:rol] = usuario.rol
							bitacora "El usuario #{usuario.descripcion} inició sesion"
							flash[:exito] = "Se guardó su nueva clave satisfactoriamente."
							success = "ok"
							bitacora "Se recuperó la clave del usuario #{usuario.descripcion} satisfactoriamente"
						else
							errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero no se pudo guardar su clave. Inténtelo nuevamente."}'
						end
					else
						errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Las claves no coinciden. Inténtelo nuevamente."}'
					end
				else
					Mailer.notificar_usuario_no_activo(usuario)
					errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Su usuario no se encuentra activo, se le ha enviado un correo para que pueda activarlo."}'
				end
			else
				errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que este enlace ha caducado."}'
			end
		else
			errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que este enlace ha caducado."}'
		end

		
		if success == "ok"
			render :json => JSON.parse('{"success":"ok"}')
		else
			bitacora "Intento fallido de recuperación de clave de usuario con id #{params[:id]}, token #{params[:token]}, clave #{params[:clave]} y confirmacion #{params[:confirmacion]}"
			render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
		end
	end

	#Vista para actualizar la clave
	def cambiar_clave
		@titulo = "Cambiar clave"
		if session[:usuario]
			@usuario = session[:usuario]
			return
		end			
		redirect_to :action => "index", :controller => "inicio"
	end

	#Método que permite cambiar la clave a través de AJAX
	def procesar_cambiar_clave
		id = params[:id]
		clave_actual = params[:clave_actual]
		clave_nueva = params[:clave_nueva]
		confirmacion = params[:confirmacion]
		errores = ""
		success = ""
		
		if id && clave_actual && clave_nueva && confirmacion
			unless session[:usuario] && id.to_i == session[:usuario].id.to_i
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar este cambio de clave."}'
			end
					
			unless errores.length > 0
				usuario = Usuario.find(id)
				if usuario.activo == 1
					unless usuario.clave == Digest::MD5.hexdigest(clave_actual)
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La clave insertada es incorrecta."}'
					end

					unless confirmacion != ""
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar la clave nueva."}'
					end

					unless clave_nueva == confirmacion
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Las claves nuevas no coinciden."}'
					end

					unless errores.length > 0
						usuario.asignar_clave(clave_nueva)
						if usuario.save
							Mailer.notificar_cambio_de_clave_exitoso(usuario)
							success = "ok"
							flash[:exito] = "Se cambio su clave satisfactoriamente."
							bitacora "Se cambió la clave del usuario #{usuario.descripcion} satisfactoriamente"
						else
							errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se pudo guardar su clave."}'							
						end
					end
				else
					Mailer.notificar_usuario_no_activo(usuario)
					errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Su usuario no se encuentra activo, se le ha enviado un correo para que pueda activarlo."}'
				end
			end
		end

		if success == "ok"
			render :json => JSON.parse('{"success":"ok"}')
		else
			bitacora "Intento fallido de cambio de clave con id #{params[:id]}, clave actual #{params[:clave_actual]}, clave nueva #{params[:clave_nueva]} y confirmacion #{params[:confirmacion]}"
			render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
		end
	end

	#Vista que muestra una asignatura en particular
	def asignatura
		if params[:id]
			id = params[:id]
			if id
				if id.gsub(/\s+/, "")
					if id.gsub(/\s+/, "").split("-")
						if id.gsub(/\s+/, "").split("-").size > 0
							if __es_codigo_de_asignatura?(id.gsub(/\s+/, "").split("-")[0])
								codigo = id.gsub(/\s+/, "").split("-")[0].to_i
								if @asignatura = Asignatura.where(:codigo => codigo).first
									@asignatura_datos = [] #En este arreglo se guardan los pares "Cedula - Nombre Apellido" de cada usuario para mostrar en el campo de busqueda
									Asignatura.order('nombre').all.each do |asignatura|
										@asignatura_datos << asignatura.codigo.to_s + " - " + asignatura.nombre.to_s
									end

									@tipos = Asignatura.order("tipo").where('tipo != "null"').collect{|x| x.tipo}.uniq
									@titulo = "Buscar Asignatura"
									return
								end
							else
								flash[:error] = "Disculpe, estos datos no pertenecen a ninguna asignatura en el sistema. Inténtelo nuevamente"
								redirect_to :action => "index"
								return
							end
						end
					end
				end
			end
		end

		flash[:error] = "Disculpe, el formato de datos de la asignatura no es correcto. Inténtelo nuevamente."
		redirect_to :action => "index"
		return
	end

	def crear_sitio_web
		if params[:modal] && params[:modal][:asignatura_id] && params[:semestre] && params[:semestre][:semestre]
			asignatura_id = params[:modal][:asignatura_id]
			periodo = params[:semestre][:semestre]

			if __es_numero_entero?(asignatura_id) && __es_periodo_valido?(periodo)
				if asignatura = Asignatura.where(:id => asignatura_id).first
					unless semestre = Semestre.where(:periodo_academico => periodo.split("-")[0], :ano_lectivo => periodo.split("-")[1]).first
						semestre = Semestre.new
						semestre.periodo_academico = periodo.split("-")[0]
						semestre.ano_lectivo = periodo.split("-")[1]
						semestre.save
						bitacora "Se creó el semestre #{semestre.periodo}"
					end
					if sitio_web = SitioWeb.where(:asignatura_id => asignatura.id, :semestre_id => semestre.id).first
						flash[:error] = "Disculpe, ya existe un sitio web para este semestre."
						redirect_to :action => "index"
						return
					else
						sitio_web = SitioWeb.new
						sitio_web.semestre_id = semestre.id
						sitio_web.asignatura_id = asignatura.id
						sitio_web.usuario_id = session[:usuario].id
						sitio_web.save
						bitacora "Se creó el sitio web de la asignatura #{sitio_web.asignatura.nombre} para el período #{sitio_web.periodo}"

						if sitio_web.asignatura.tiene_varios_sitios_web
							flash[:mensaje] = "Bienvenido a un nuevo período de #{asignatura.nombre}. Por favor verifica el grupo docente."
							redirect_to :asignatura_nombre => asignatura.nombre_url, :semestre => periodo, :controller => "grupo_docente", :action => "index"
						else
							flash[:exito] = "Bienvenido al sitio web de #{asignatura.nombre} del semestre #{periodo}"
							redirect_to :asignatura_nombre => asignatura.nombre_url, :semestre => periodo, :controller => "bienvenida", :action => "index"
						end
						return
					end
				end
			else
				flash[:error] = "Disculpe, parece que hubo un error."
				bitacora "Intento fallido al crear sitio web asignatura_id #{asignatura_id} y semestre #{periodo}"
				redirect_to :action => "index"
				return
			end
		end

		bitacora "Intento fallido al crear sitio web sin parámetros"
		flash[:error] = "Disculpe, no puede acceder a esta dirección."
		redirect_to :action => "index", :controller => "inicio"
		return
	end
	
	def agregar_asignatura
		if session[:usuario] && Docente.where(:id => session[:usuario].id).size > 0
			@carreras = ["Biología", "Computación", "Geoquímica", "Física", "Matemática", "Química", "Complementaria"]
			@clasificaciones = ["Semestre I", "Semestre II", "Semestre III", "Semestre IV", "Semestre V", 
													"Semestre VI", "Semestre VII", "Semestre VIII", "Semestre IX", "Semestre X"]
			#@carreras = Carrera.order("nombre").all.collect{|x| x.nombre}.uniq

			@menciones = []
			#if Carrera.where(:nombre => "Generales").size > 0
			#	@menciones = Mencion.order("nombre").where(:carrera_id => Carrera.where(:nombre => "Generales").first.id).collect{|x| x.nombre}.uniq
			#end

			@tipos = ["Obligatoria","Electiva", "Obligatoria optativa", "Complementaria", "Otra"]
			@titulo = "Agregar Asignatura Nueva"			
		else
			redirect_to :action => "index", :controller => "inicio"
			return
		end
	end

	#Metodo que agrega una asignatura al sistema y retorna una respuesta a través de AJAX
	def procesar_agregar_asignatura
		errores = ""
		parametros = ""
		
		#Se guardan los parametros en variables locales para mejor manejo del sistema
		codigo = params[:codigo]
		nombre = params[:nombre]
		carreras_dato = params[:carreras]
		uc = params[:unidades_credito]
		clasificacion = params[:clasificacion]
		tipo = params[:tipo]
		requisitos = params[:requisitos]

		if session[:usuario] && Docente.where(:id => session[:usuario].id).size > 0
		
			#Se validan los campos, cada una de estas validaciones son globales para los controladores,
			# por lo que se encuentran en application_controller.rb
			if codigo == nil || codigo == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el código."}'
			elsif !__es_codigo_de_asignatura?(codigo)
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El código debe estar conformado por cuatro (4) números."}'
			end

			if nombre == nil || nombre == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre."}'
			end

			if carreras_dato == nil
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe seleccionar alguna carrera."}'
			end
			
			if uc == nil || uc == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar las unidades de crédito."}'
			elsif !__es_numero_entero?(uc)
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Las unidades de crédito deben ser numéricas."}'
			end
			
			if tipo == nil || tipo == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el tipo."}'
			end


			if tipo == "Obligatoria"
				if !__es_semestre_valido?(clasificacion)
					errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe seleccionar un semestre."}'
				end
			elsif tipo == "Electiva" || tipo == "Obligatoria optativa"
				if clasificacion == nil
					errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe seleccionar alguna mencion."}'
				else
					clasificacion.each_with_index do |dato, i|
						clas = JSON.parse(dato, nil);
						if clas["clasificacion"] == nil || clas["clasificacion"] == ""
							errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la mención '+(i+1).to_s+'."}'
						end
					end
				end
			end


			unless errores.length > 0
				#Si los datos son correctos, se verifica que no exista una asignatura con ese codigo
				if asignatura = Asignatura.where(:codigo => codigo).first
					if Asignatura.where("id != ? AND nombre = ?",asignatura.id,nombre).size > 0
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe una asignatura en el sistema con este nombre."}'
					end
				else
					asignatura = Asignatura.new
					asignatura.codigo = codigo
					if Asignatura.where(:nombre => nombre).size > 0
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe una asignatura en el sistema con este nombre."}'
					end
				end

				unless errores.length > 0
					#De llegar a este punto, los datos son correctos, por lo que se crea y guarda la asignatura	
					asignatura.nombre = nombre
					#asignatura.carrera_id = Carrera.where(:nombre => carrera).first.id
					asignatura.unidades_credito = uc

					asignatura.requisitos = requisitos

					asignatura.tipo = tipo

					if asignatura.save
						bitacora "Se guardó la asignatura #{asignatura.id} - #{asignatura.nombre} satisfactoriamente."

						carreras = []
						#Se guardan las carreras en un array para su manejo
						carreras_dato.each_with_index do |dato, i|
							carrera = JSON.parse(dato, nil);
							carreras << carrera["carrera"]
						end

						#Se guardan las asignaturas carreras
						carreras.each do |carrera|
							unless carrera_nueva = Carrera.where(:nombre => carrera).first
								carrera_nueva = Carrera.new
								carrera_nueva.nombre = carrera
								if carrera_nueva.save
									bitacora "Se guardó la asignatura #{asignatura.id} - #{asignatura.nombre} satisfactoriamente."
								else
									bitacora "No se pudo crear la carrera #{carrera}"
									errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se pudo crear la carrera."}'
								end
							end

							unless AsignaturaCarrera.where(:asignatura_id => asignatura.id, :carrera_id => carrera_nueva.id).size > 0
								asignatura_carrera = AsignaturaCarrera.new
								asignatura_carrera.asignatura_id = asignatura.id
								asignatura_carrera.carrera_id = carrera_nueva.id
								if asignatura_carrera.save
									bitacora "Se creó la asignatura carrera #{asignatura_carrera.id}"
								else
									bitacora "No se pudo crear la asignatura carrera con asignatura #{asignatura.id} y carrera #{carrera_nueva.id}"
								end
							end
						end

						#Ahora se eliminan las asignaturas carreras que no se consideraron en el sistema
						AsignaturaCarrera.where(:asignatura_id => asignatura.id).each do |asignatura_carrera|
							esta = false
							carreras.each do |carrera|
								if asignatura_carrera.carrera.nombre == carrera
									esta = true
									break
								end
							end

							if !esta
								texto = "Se borró las asignatura carrera #{asignatura_carrera.id}"
								asignatura_carrera.destroy
								bitacora texto
							end
						end


						#Segun el tipo se guardaran las clasificaciones o las menciones
						if tipo == "Electiva" || tipo == "Obligatoria optativa"

							menciones = []
							#Se guardan las menciones en un array para su manejo
							clasificacion.each_with_index do |dato, i|
								mencion = JSON.parse(dato, nil);
								menciones << mencion["clasificacion"]
								
							end


							#Se guardan las asignaturas menciones
							menciones.each do |mencion|

								#Se guardan las menciones que no existan en el sistema
								unless mencion_nueva = Mencion.where(:nombre => mencion).first
									mencion_nueva = Mencion.new
									mencion_nueva.nombre = mencion
									if mencion_nueva.save
										bitacora "Se guardó la mencion #{mencion} satisfactoriamente."
									else
										bitacora "No se pudo crear la mencion #{mencion}"
										errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se pudo crear la mencion."}'
									end
								end



								#Se guardar la relacion entre las menciones y carreras que no existan previamente
								carreras.each do |carrera|
									carrera_id = Carrera.where(:nombre => carrera).first.id
									unless mencion_carrera = MencionCarrera.where(:mencion_id => mencion_nueva.id, :carrera_id => carrera_id).first
										mencion_carrera = MencionCarrera.new
										mencion_carrera.carrera_id = carrera_id
										mencion_carrera.mencion_id = mencion_nueva.id
										if mencion_carrera.save
											bitacora "Se guardó la carrera mencion #{mencion_carrera.id} satisfactoriamente."
										else
											bitacora "No se pudo crear la carrera mencion #{carrera} - #{mencion_nueva.nombre}"
											errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se pudo crear la carrera mencion."}'
										end
									end
								end

								unless asignatura_mencion = AsignaturaMencion.where(:asignatura_id => asignatura.id, :mencion_id => mencion_nueva.id).first
									asignatura_mencion = AsignaturaMencion.new
									asignatura_mencion.asignatura_id = asignatura.id
									asignatura_mencion.mencion_id = mencion_nueva.id
									if asignatura_mencion.save
										bitacora "Se creó la asignatura mencion #{asignatura_mencion.id}"
									else
										bitacora "No se pudo crear la asignatura mencion con asignatura #{asignatura.id} y mencion #{mencion_nueva.id}"
									end
								end
							end

							#Ahora se eliminan las asignaturas menciones que no se consideraron en el sistema
							AsignaturaMencion.where(:asignatura_id => asignatura.id).each do |asignatura_mencion|
								esta = false
								menciones.each do |mencion|
									if asignatura_mencion.mencion.nombre == mencion
										esta = true
										break
									end
								end

								if !esta
									texto = "Se borró las asignatura mencion #{asignatura_mencion.id}"
									asignatura_mencion.destroy
									bitacora texto
								end
							end

							if asignatura_clasificacion = AsignaturaClasificacion.where(:asignatura_id => asignatura.id).first
								texto = "Se eliminó la asignatura clasificacion #{asignatura.nombre} - #{asignatura_clasificacion.clasificacion.nombre}"
								asignatura_clasificacion.destroy
								bitacora texto
							end

						else
							if tipo == "Obligatoria"
								#Las asignaturas obligatorias se clasifican en semestres

								#Se guardan los semestres que no existan en BD
								unless clasificacion_nueva = Clasificacion.where(:nombre => clasificacion).first
									clasificacion_nueva = Clasificacion.new
									clasificacion_nueva.nombre = clasificacion
									if clasificacion_nueva.save
										bitacora "Se guardó la clasificacion #{clasificacion_nueva.id} satisfactoriamente."
									else
										bitacora "No se pudo crear la clasificacion #{clasificacion}"
										errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se pudo crear la clasificacion."}'
									end
								end

								#Se guardan la clasificacion de la asignatura sea nueva o editada
								unless asignatura_clasificacion = AsignaturaClasificacion.where(:asignatura_id => asignatura.id).first
									asignatura_clasificacion = AsignaturaClasificacion.new
									asignatura_clasificacion.asignatura_id = asignatura.id
								end

								asignatura_clasificacion.clasificacion_id = clasificacion_nueva.id
								if asignatura_clasificacion.save
									bitacora "Se creó la asignatura clasificacion #{asignatura_clasificacion.id}"
								else
									bitacora "No se pudo crear la asignatura clasificacion con asignatura #{asignatura.id} y carrera #{clasificacion_nueva.id}"
								end
							
							else
								if asignatura_clasificacion = AsignaturaClasificacion.where(:asignatura_id => asignatura.id).first
									texto = "Se eliminó la asignatura clasificacion #{asignatura.nombre} - #{asignatura_clasificacion.clasificacion.nombre}"
									asignatura_clasificacion.destroy
									bitacora texto
								end
							end

							if AsignaturaMencion.where(:asignatura_id => asignatura.id).size > 0
								AsignaturaMencion.where(:asignatura_id => asignatura.id).each do |asignatura_mencion|
									texto = "Se eliminó la asignatura mencion #{asignatura.nombre} - #{asignatura_mencion.mencion.nombre}"
									asignatura_mencion.destroy
									bitacora texto
								end
							end
						end

						Mencion.where("id not in (?)", AsignaturaMencion.all().collect{|x| x.mencion_id}).each do |mencion|
							texto = "Se eliminó la mención #{mencion.nombre}"
							mencion.destroy
							bitacora texto
						end
						
						success = "ok"
						flash[:exito] = "Se agregó la asignatura #{asignatura.nombre} satisfactoriamente."
					end
				end
			end
		else #No es docente
			bitacora "Ingreso no autorizado a procesar_agregar_asignatura"
			errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar esta acción."}'
		end

		if success == "ok"
			render :json => JSON.parse('{"success":"ok", "url": "/inicio/index/'+asignatura.asignatura_carrera.first.carrera.nombre+'"}')
		else
			bitacora "Intento fallido de agregacion de asignatura con código #{params[:codigo]}, nombre #{params[:nombre]}, carrera #{params[:carrera]}, unidades de crédito #{params[:unidades_credito]}, clasificacion #{params[:clasificacion]} y tipo #{params[:tipo]} del docente #{session[:usuario].descripcion}" if session[:usuario]
			render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
		end
	end

	def eliminar_sitio_web
		if session[:usuario] && params[:id] && __es_numero_entero?(params[:id]) && SitioWeb.where(:id => params[:id]).size > 0 
			sitio_web = SitioWeb.where(:id => params[:id]).first
			if sitio_web.creador.id == session[:usuario].id
				texto = "Se eliminó el sitio web de la asignatura #{sitio_web.asignatura.nombre} para el período #{sitio_web.periodo}"
				sitio_web.destroy
				bitacora texto
				flash[:mensaje] = "Se eliminó el sitio web satisfactoriamente."
				redirect_to :controller => "inicio", :action => "index"
				return
			end
		end

		redirect_to :back
		return
	end
end
