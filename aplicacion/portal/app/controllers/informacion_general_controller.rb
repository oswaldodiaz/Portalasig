# -*- encoding : utf-8 -*-
class InformacionGeneralController < ApplicationController
	layout "sitio_web"

	before_filter "verificar_sitio_web"
	before_filter :es_ajax?, :only => [:procesar_editar_asignatura]

	def index
		@bienvenida = params[:bienvenida] if params[:bienvenida]
		
    @seccion = "informacion_general"
		@es_del_grupo_docente = __es_del_grupo_docente
		@sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
	end

	def editar
		if __es_del_grupo_docente
	    @seccion = "informacion_general"
	    @es_del_grupo_docente = __es_del_grupo_docente
			@sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

			@clasificaciones = ["Semestre I", "Semestre II", "Semestre III", "Semestre IV", "Semestre V", 
													"Semestre VI", "Semestre VII", "Semestre VIII", "Semestre IX", "Semestre X"]

			@tipos = ["Obligatoria","Electiva", "Obligatoria optativa", "Complementaria", "Otra"]


			@menciones = Mencion.where(:id => 
											MencionCarrera.where(:carrera_id => 
												AsignaturaCarrera.where(:asignatura_id => @sitio_web.asignatura_id).collect{|x| x.carrera_id}
											).collect{|x| x.mencion_id}
									 ).collect{|x| x.nombre}
			@menciones << "Otra"

	  else
	    redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
	    return 
	  end
	end 

	def procesar_editar_asignatura
		errores = ""
		success = ""
		
		if __es_del_grupo_docente 
					
			#Se guardan los parametros en variables locales para mejor manejo del sistema
			codigo = params[:codigo]
			nombre = params[:nombre]
			uc = params[:unidades_credito]
			clasificacion = params[:clasificacion]
			tipo = params[:tipo]
			requisitos = params[:requisitos]


			if codigo == nil || codigo == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar el código."}'
			elsif !__es_codigo_de_asignatura?(codigo)
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El código debe estar conformado por cuatro (4) números."}'
			end

			if nombre == nil || nombre == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar el nombre."}'
			end

			if uc == nil || uc == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar las unidades de crédito."}'
			elsif !__es_numero_entero?(uc)
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Las unidades de crédito debe ser numéricas"}'
			end

			if tipo == nil || tipo == ""
				errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe seleccionar algún tipo."}'
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
				#Si los datos son correctos, se verifica que no exista una asignatura con ese código y ese nombre
				if Asignatura.where("id != ? AND codigo = ?",@sitio_web.asignatura.id,codigo).size > 0
					errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe una asignatura en el sistema con este código."}'
				end

				if Asignatura.where("id != ? AND nombre = ?",@sitio_web.asignatura.id,nombre).size > 0
					errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe una asignatura en el sistema con este nombre."}'
				end


				#Los datos son correctos y se procede a almacenar la información
				unless errores.length > 0
			
					asignatura = @sitio_web.asignatura

					asignatura.codigo = codigo
					asignatura.nombre = nombre
					asignatura.unidades_credito = uc
					asignatura.tipo = tipo
					asignatura.requisitos = requisitos

					if asignatura.save
						bitacora "Se guardó la asignatura #{asignatura.id} - #{asignatura.nombre} satisfactoriamente."

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
								@sitio_web.asignatura.asignatura_carrera.each do |asignatura_carrera|
									unless mencion_carrera = MencionCarrera.where(:mencion_id => mencion_nueva.id, :carrera_id => asignatura_carrera.carrera_id).first
										mencion_carrera = MencionCarrera.new
										mencion_carrera.carrera_id = asignatura_carrera.carrera_id
										mencion_carrera.mencion_id = mencion_nueva.id
										if mencion_carrera.save
											bitacora "Se guardó la carrera mencion #{mencion_carrera.id} satisfactoriamente."
										else
											bitacora "No se pudo crear la carrera mencion #{asignatura_carrera.carrera_id} - #{mencion_nueva.nombre}"
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
									#mencion_id = asignatura_mencion.mencion_id
									mencion_id = asignatura_mencion.mencion_id
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
						flash[:exito] = "Se guardó la información general de la asignatura satisfactoriamente."
					else
						errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se pudo guardar la asignatura."}'
					end
				end
			end


		else
			errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar esta acción. #{__es_del_grupo_docente} #{params[:id]} #{params[:codigo]} #{params[:nombre]} #{params[:clasificacion]} #{params[:requisitos]} #{params[:id]} #{params[:unidades_credito]}" }'
		end
	
    if success == "ok"
			render :json => JSON.parse('{"success":"ok", "url": "/'+@sitio_web.nombre_url+'/'+@sitio_web.periodo+'/informacion_general/index"}')
		else
			bitacora "Intento fallido de agregacion de asignatura con código #{params[:codigo]}, nombre #{params[:nombre]}, carrera #{params[:carrera]}, unidades de crédito #{params[:unidades_credito]} y tipo #{params[:tipo]} del docente #{session[:usuario].descripcion}" if session[:usuario]
			render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
		end
	end

end
