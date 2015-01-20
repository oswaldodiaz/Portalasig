# -*- encoding : utf-8 -*-
class AjaxController < ApplicationController

	before_filter :es_ajax?

	def buscar_asignatura_por_codigo_y_nombre
		if params[:id]
			id = params[:id]
			if id
				if id.gsub(/\s+/, "")
					if id.gsub(/\s+/, "").split("-")
						if id.gsub(/\s+/, "").split("-").size > 0
							if __es_codigo_de_asignatura?(id.gsub(/\s+/, "").split("-")[0])
								codigo = id.gsub(/\s+/, "").split("-")[0].to_i
								if @asignatura = Asignatura.where(:codigo => codigo).first
									render :json => JSON.parse('{"success":"ok"}')
									return
								end
							end
						end
					end
				end
			end
		end
		errores = '{"error":"No se encuentra ninguna asignatura en el sistema con estos parámetros."}'
		render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
	end

	def buscar_docente_por_cedula_y_nombre
		id = params[:id]
		if id && id.gsub(/\s+/, "") && id.gsub(/\s+/, "").split("-").size > 0 && __es_numero_entero?(id.gsub(/\s+/, "").split("-")[0])
			cedula = id.gsub(/\s+/, "").split("-")[0]
			if Usuario.where(:cedula => cedula).size > 0 && Usuario.where(:cedula => cedula).first.es_docente?
				render :json => JSON.parse('{"success":"ok"}')
				return
			end
		end
		errores = '{"error":"No se encuentra ningún docente en el sistema con estos parámetros."}'
		render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
	end

	def buscar_estudiante_por_cedula_y_nombre
		id = params[:id]
		if id && id.gsub(/\s+/, "") && id.gsub(/\s+/, "").split("-").size > 0 && __es_numero_entero?(id.gsub(/\s+/, "").split("-")[0])
			cedula = id.gsub(/\s+/, "").split("-")[0]
			if Usuario.where(:cedula => cedula).size > 0 && Usuario.where(:cedula => cedula).first.es_estudiante?
				render :json => JSON.parse('{"success":"ok"}')
				return
			end
		end
		errores = '{"error":"No se encuentra ningún estudiante en el sistema con estos parámetros."}'
		render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
	end

	def buscar_asignatura_por_codigo
		respuesta = "";
		codigo = params[:codigo]
		if __es_codigo_de_asignatura?(codigo)
			if asignatura = Asignatura.where(:codigo => codigo).first
				tipo_string = ""
				AsignaturaCarrera.where(:asignatura_id => asignatura.id).each_with_index do |asignatura_carrera,i|
					tipo_string += ( (i == 0)? "{" : ", {") + '"nombre":"'+asignatura_carrera.carrera.nombre+'"}'
				end

				menciones_string = ""
				MencionCarrera.where(:carrera_id => 
					AsignaturaCarrera.where(:asignatura_id => asignatura.id).collect{|x| x.carrera_id}
					).each_with_index do |mencion_carrera,i|
					menciones_string += ( (i == 0)? "{" : ", {") + '"nombre":"'+mencion_carrera.mencion.nombre+'"}'
				end

				clasificacion = '""'
				if asignatura.tipo == "Obligatoria"
					clasificacion = '"'+asignatura.asignatura_clasificacion.clasificacion.nombre+'"'
				elsif asignatura.tipo == "Electiva" || asignatura.tipo == "Obligatoria optativa"
					mencion_string = ""
					asignatura.asignatura_mencion.each_with_index do |asignatura_mencion,i|
						mencion_string += ( (i == 0)? "{" : ", {") + '"nombre":"'+asignatura_mencion.mencion.nombre+'"}'
					end
					clasificacion = "["+mencion_string+"]"
				end						

				requisitos = ""
				requisitos = asignatura.requisitos if asignatura.requisitos

				algo = '{"nombre":"'+asignatura.nombre+'", "carrera":['+tipo_string+'], "unidades_credito":"';
				algo += asignatura.unidades_credito.to_s+'", "requisitos":"'+requisitos+'", "tipo":"';
				algo += asignatura.tipo+'","clasificacion":'+clasificacion+', "menciones":['+menciones_string+'] }'
				respuesta = JSON.parse(algo)
			end
		end

		render :json => respuesta
	end

	def buscar_carrera_por_asignatura
		asignaturas = []
		id = params[:id]
		if __es_numero_entero?(id)
			if Asignatura.where(:id => id).size > 0
				asignatura = Asignatura.where(:id => id).first
				asignaturas << JSON.parse('{"nombre":"'+asignatura.nombre+'", "carrera":"'+asignatura.carrera.nombre+'"}')
			end
		end
		render :json => asignaturas
	end

	def buscar_usuario_por_cedula
		usuario = nil
		cedula = params[:cedula]
		if __es_numero_entero?(cedula)
			if Usuario.where(:cedula => cedula).size > 0
				usuario = Usuario.where(:cedula => cedula).first
			end
		end
		render :json => usuario
	end

	def buscar_menciones_por_carreras
		menciones = ""
		if params[:carreras]
			menciones = []
			carreras = params[:carreras]

			array = []
			carreras.each_with_index do |dato, i|
				carrera = JSON.parse(dato, nil)
				array << carrera["carrera"]
			end

			carreras = Carrera.where(:nombre => array)
			if carreras.size > 0
				if MencionCarrera.where(:carrera_id => Carrera.where(:nombre => array).collect{|x| x.id}).size > 0
					if Mencion.where(:id => MencionCarrera.where(:carrera_id => Carrera.where(:nombre => array).collect{|x| x.id}).collect{ |x| x.mencion_id}).size > 0

						tipo_string = ""
						Mencion.order("nombre").where(:id => MencionCarrera.where(:carrera_id => Carrera.where(:nombre => array).collect{|x| x.id}).collect{ |x| x.mencion_id}).each_with_index do |mencion,i|
						tipo_string += ( (i == 0)? "{" : ", {") + '"nombre":"'+mencion.nombre+'"}'
						end

						menciones = JSON.parse('{"menciones":['+tipo_string+'] }')
					end
				end
			end
		end		
		render :json => menciones
	end

	def buscar_semestres_disponibles_para_asignatura_por_id
		semestres = []
		id = params[:id]
		if id && __es_numero_entero?(id) && Asignatura.where(:id => id).first
			asignatura = Asignatura.find(id)
			fecha = Time.now
			ano_lectivo = fecha.year

			semestres_array = []
			for i in -1..1 do 
				semestres_array << Semestre.semestre("1",ano_lectivo.to_i+i)
				semestres_array << Semestre.semestre("I",ano_lectivo.to_i+i)
				semestres_array << Semestre.semestre("2",ano_lectivo.to_i+i)
			end

			pos = 0
			semestres_array.each_with_index do |semestre, index|
				if SitioWeb.where(:asignatura_id => asignatura.id, :semestre_id => semestre.id).size > 0
					pos = index.to_i + 1
				end
			end

			for i in pos..semestres_array.length-1 do 
				semestres << semestres_array[i]
			end

		end
		render :json => semestres
	end

	def buscar_docente_sitio_web_por_cedula
		docentes = []
		if params[:cedula] && params[:sitio_web_id]
			cedula = params[:cedula]
			sitio_web_id = params[:sitio_web_id]
			if __es_numero_entero?(cedula) && __es_numero_entero?(sitio_web_id)
				if usuario = Usuario.where(:cedula => cedula).first				
					if docente = Docente.where(:id => usuario.id).first
						tipo = ""
						seccion = ""
						correo = docente.usuario.correo

						if docente_asignatura = DocenteSitioWeb.where(:sitio_web_id => sitio_web_id, :docente_id => docente.id).first
							tipo = docente_asignatura.tipo if docente_asignatura.tipo != nil
							seccion = docente_asignatura.seccion.nombre if docente_asignatura.seccion_id != nil
							correo = docente_asignatura.correo if docente_asignatura.correo != nil
						end

						usuario_string = ""
						Usuario.where(:id => Docente.all).collect{ |x| x.cedula}.uniq.each_with_index do |usuario, i|
							usuario_string += ( (i == 0)? "{" : ", {") + '"usuario":"'+usuario.to_s+'"}'
						end

						seccion_string = ""
						Seccion.order("nombre").all.collect{ |x| x.nombre}.uniq.each_with_index do |seccion, i|
							seccion_string += ( (i == 0)? "{" : ", {") + '"seccion":"'+seccion+'"}'
						end

						tipo_string = ""
						DocenteSitioWeb.order("tipo").where("tipo != ? ", "").collect{|x| x.tipo}.uniq.each_with_index do |tipo, i|
							tipo_string += ( (i == 0)? "{" : ", {") + '"tipo":"'+tipo+'"}'
						end

						docentes << JSON.parse('{"cedula":"'+usuario.cedula.to_s+'",
																		 "nombre":"'+usuario.nombre_y_apellido+'",
																		  "correo":"'+correo+'",
																		  "seccion":"'+seccion+'",
																		  "tipo":"'+tipo+'",
																		   "usuarios":['+usuario_string+'],
																		   "secciones":['+seccion_string+'],
																		   "tipos":['+tipo_string+'] }')
					end
				end
			end
		end

		render :json => docentes
	end


	def buscar_preparador_por_cedula
		preparadores = []
		nombre = ""
		apellido = ""
		correo = ""
		seccion = ""
		tipo = ""
		if params[:cedula] && params[:sitio_web_id]
			cedula = params[:cedula]
			sitio_web_id = params[:sitio_web_id]
			if __es_numero_entero?(cedula) && __es_numero_entero?(sitio_web_id)
				if usuario = Usuario.where(:cedula => cedula).first		
					nombre = usuario.nombre_y_apellido
					apellido  =usuario.apellido
					if estudiante = Estudiante.where(:id => usuario.id).first
						correo = estudiante.usuario.correo

						if preparador = Preparador.where(:sitio_web_id => sitio_web_id, :estudiante_id => estudiante.id).first
							tipo = preparador.tipo if preparador.tipo != nil
							seccion = preparador.seccion.nombre if preparador.seccion_id != nil
							correo = preparador.correo if preparador.correo != nil
						end
					end
				end
			end
		end

		usuario_string = ""
		Usuario.where(:id => Estudiante.all).collect{ |x| x.cedula}.uniq.each_with_index do |usuario, i|
			usuario_string += ( (i == 0)? "{" : ", {") + '"usuario":"'+usuario.to_s+'"}'
		end

		seccion_string = ""
		Seccion.order("nombre").all.collect{ |x| x.nombre}.uniq.each_with_index do |seccion, i|
			seccion_string += ( (i == 0)? "{" : ", {") + '"seccion":"'+seccion+'"}'
		end

		tipo_string = ""
		Preparador.order("tipo").where("tipo != ? ", "").collect{|x| x.tipo}.uniq.each_with_index do |tipo, i|
			tipo_string += ( (i == 0)? "{" : ", {") + '"tipo":"'+tipo+'"}'
		end

		preparadores << JSON.parse('{"cedula":"'+cedula.to_s+'",
																 "nombre":"'+nombre+'",
																  "correo":"'+correo+'",
																  "seccion":"'+seccion+'",
																  "tipo":"'+tipo+'",
																   "usuarios":['+usuario_string+'],
																   "secciones":['+seccion_string+'],
																   "tipos":['+tipo_string+'] }')
		render :json => preparadores
	end

	def eventos
		@events = nil
    @events = Evento.where(:sitio_web_id => params[:id]) if params[:id]
    render :json => @events
  end

  def buscar_datos_horarios
		tipos = ""
		Horario.all().collect{ |x| x.tipo}.uniq.each_with_index do |tipo, i|
			tipos += ( (i == 0)? "{" : ", {") + '"tipo":"'+tipo.to_s+'"}'
		end

		aulas = ""
		Horario.all().collect{ |x| x.aula}.uniq.each_with_index do |aula, i|
			aulas += ( (i == 0)? "{" : ", {") + '"aula":"'+aula.to_s+'"}'
		end

		datos = JSON.parse('{"tipos":['+tipos+'],
													"aulas":['+aulas+'] }')

		render :json => datos
	end
end
