#encoding: utf-8

class ArchivoController < ApplicationController

	def cargar_docentes
		flash[:errores] = []
		
		unless params[:ruta]
			flash[:errores] << "Debe seleccionar la lista de docentes."
			redirect_to :action => "agregar_docente", :controller => "admin"
			return
		end

		ruta = params[:ruta]

		array = ruta.split(".")

		if array[array.length-1] == "xls"
			documento = Roo::Excel.new(ruta)
		elsif array[array.length-1] == "xlsx"
			documento = Roo::Excelx.new(ruta)
		elsif array[array.length-1] == "ods"
			documento = Roo::Openoffice.new(ruta)
		else
			flash[:errores] << "Disculpe, se espera una hoja de cálculo (.xls, .xlsx o .ods). Inténtelo nuevamente."
			redirect_to :action => "agregar_docente", :controller => "admin"
			return
		end
				
		documento.default_sheet = documento.sheets.first

		#Se inicializa la primera celda (1,2)
		i = 0

		cedulas = []
		nombres = []
		apellidos = []
		correos = []

		#Este ciclo itera sobre todos los docentes de la lista, siempre y cuando las celdas respectivas no esté vacías
		2.upto(documento.last_row) do |line|
			#Se leen la primera fila: cedula, nombres, apellidos y correo.

			cedulas[i] = documento.cell(line,'A')
			nombres[i] = documento.cell(line,'B')
			apellidos[i] = documento.cell(line,'C')
			correos[i] = documento.cell(line,'D')

			fila = (line).to_s

			#Se validan los campos, cada una de estas validaciones son globales para los controladores,
			# por lo que se encuentran en application_controller.rb
			if cedulas[i] == nil || cedulas[i] == ""
				flash[:errores] << "Debe insertar la cédula de la fila #{fila}."
			else
				cedulas[i] = cedulas[i].to_s
				if __es_numero_flotante?(cedulas[i])
					cedulas[i] = cedulas[i].to_i.to_s
				end

				if !__es_numero_entero?(cedulas[i])
					flash[:errores] << "La cédula de la fila #{fila} debe ser numérica."
				end
			end

			if nombres[i] == nil || nombres[i] == ""
				flash[:errores] << "Debe insertar los nombre de la fila #{fila}."
			end

			if apellidos[i] == nil || apellidos[i] == ""
				flash[:errores] << "Debe insertar los apellidos de la fila #{fila}."
			end

			if correos[i] == nil || correos[i] == ""
				flash[:errores] << "Debe insertar el correo de la fila #{fila}."
			elsif !__es_correo?(correos[i])
				flash[:errores] << "El correo de la fila #{fila} no tiene el formato adecuado."
			end
			
			unless flash[:errores].length > 0
				#Si los datos son correctos, se verifica que no exista un codente con esta cédula
				if usuario = Usuario.where(:cedula => cedulas[i]).first
					if Usuario.where("id != ? AND correo = ?", usuario.id, correos[i]).size > 0
						flash[:errores] << "El correo de la fila #{fila} ya pertenece a un usuario en el sistema"
					end
				elsif Usuario.where(:correo => correos[i]).size > 0
					flash[:errores] << "El correo de la fila #{fila} ya pertenece a un usuario en el sistema"
				end
			end

			i += 1
			celda = documento.cell(i,1)
		end

		if cedulas.length > 0
			unless flash[:errores].length > 0
				#Si los datos son correctos, se verifica que no exista una asignatura con ese codigo
				for i in 0..cedulas.length-1 do
					ya_estaba = true
					unless usuario = Usuario.where(:cedula => cedulas[i]).first
						usuario = Usuario.new
						usuario.cedula = cedulas[i]
						ya_estaba = false
					end

					usuario.nombre = nombres[i]
					usuario.apellido = apellidos[i]
					usuario.correo = correos[i]

					if usuario.save
						Mailer.registro_de_usuario(usuario) unless ya_estaba
			
						unless Docente.where(:id => usuario.id).size > 0
							docente = Docente.new
							docente.id = usuario.id
							docente.save
							bitacora "Se guardó al docente #{usuario.id} - #{usuario.nombre} satisfactoriamente."
						end
					end
				end
			end

			unless flash[:errores].length > 0
				flash[:exito] = "Se guardaron todos los docentes exitosamente."
				redirect_to :action => "docentes", :controller => "admin"
				return
			end

		else
			flash[:errores] << "Parece que el archivo está vacío"
		end
		redirect_to :action => "agregar_docente", :controller => "admin"
	end

	def cargar_estudiantes
		flash[:errores] = []
		
		unless params[:ruta]
			flash[:errores] << "Debe seleccionar la lista de estudiantes."
			redirect_to :action => "agregar_estudiante", :controller => "admin"
			return
		end

		ruta = params[:ruta]

		array = ruta.split(".")

		if array[array.length-1] == "xls"
			documento = Roo::Excel.new(ruta)
		elsif array[array.length-1] == "xlsx"
			documento = Roo::Excelx.new(ruta)
		elsif array[array.length-1] == "ods"
			documento = Roo::Openoffice.new(ruta)
		else
			flash[:errores] << "Disculpe, se espera una hoja de cálculo (.xls, .xlsx o .ods). Inténtelo nuevamente."
			redirect_to :action => "agregar_estudiante", :controller => "admin"
			return
		end
				
		documento.default_sheet = documento.sheets.first

		#Se inicializa la primera celda (1,2)
		i = 0

		cedulas = []
		nombres = []
		apellidos = []
		correos = []

		#Este ciclo itera sobre todos los docentes de la lista, siempre y cuando las celdas respectivas no esté vacías
		2.upto(documento.last_row) do |line|
			#Se leen la primera fila: cedula, nombres, apellidos y correo.

			cedulas[i] = documento.cell(line,'A')
			nombres[i] = documento.cell(line,'B')
			apellidos[i] = documento.cell(line,'C')
			correos[i] = documento.cell(line,'D')

			fila = (line).to_s

			#Se validan los campos, cada una de estas validaciones son globales para los controladores,
			# por lo que se encuentran en application_controller.rb
			if cedulas[i] == nil || cedulas[i] == ""
				flash[:errores] << "Debe insertar la cédula de la fila #{fila}."
			else
				cedulas[i] = cedulas[i].to_s
				if __es_numero_flotante?(cedulas[i])
					cedulas[i] = cedulas[i].to_i.to_s
				end

				if !__es_numero_entero?(cedulas[i])
					flash[:errores] << "La cédula de la fila #{fila} debe ser numérica."
				end
			end

			if nombres[i] == nil || nombres[i] == ""
				flash[:errores] << "Debe insertar los nombre de la fila #{fila}."
			end

			if apellidos[i] == nil || apellidos[i] == ""
				flash[:errores] << "Debe insertar los apellidos de la fila #{fila}."
			end

			if correos[i] == nil || correos[i] == ""
				flash[:errores] << "Debe insertar el correo de la fila #{fila}."
			elsif !__es_correo?(correos[i])
				flash[:errores] << "El correo de la fila #{fila} no tiene el formato adecuado."
			end
			
			unless flash[:errores].length > 0
				#Si los datos son correctos, se verifica que no exista un codente con esta cédula
				if usuario = Usuario.where(:cedula => cedulas[i]).first
					if Usuario.where("id != ? AND correo = ?", usuario.id, correos[i]).size > 0
						flash[:errores] << "El correo de la fila #{fila} ya pertenece a un usuario en el sistema"
					end
				elsif Usuario.where(:correo => correos[i]).size > 0
					flash[:errores] << "El correo de la fila #{fila} ya pertenece a un usuario en el sistema"
				end
			end

			i += 1
			celda = documento.cell(i,1)
		end

		if cedulas.length > 0
			unless flash[:errores].length > 0
				#Si los datos son correctos, se verifica que no exista una asignatura con ese codigo
				for i in 0..cedulas.length-1 do
					ya_estaba = true
					unless usuario = Usuario.where(:cedula => cedulas[i]).first
						usuario = Usuario.new
						usuario.cedula = cedulas[i]
						ya_estaba = false
					end

					usuario.nombre = nombres[i]
					usuario.apellido = apellidos[i]
					usuario.correo = correos[i]

					if usuario.save
						Mailer.registro_de_usuario(usuario) unless ya_estaba
			
						unless Estudiante.where(:id => usuario.id).size > 0
							estudiante = Estudiante.new
							estudiante.id = usuario.id
							estudiante.save
							bitacora "Se guardó al estudiante #{usuario.id} - #{usuario.nombre} satisfactoriamente."
						end
					end
				end
			end

			unless flash[:errores].length > 0
				flash[:exito] = "Se guardaron todos los estudiantes exitosamente."
				redirect_to :action => "estudiantes", :controller => "admin"
				return
			end

		else
			flash[:errores] << "Parece que el archivo está vacío"
		end
		redirect_to :action => "agregar_estudiante", :controller => "admin"
	end

	def cargar_asignaturas
		flash[:errores] = []
		
		unless params[:ruta]
			flash[:errores] << "Debe seleccionar la lista de asignaturas"
			redirect_to :action => "agregar_asignatura", :controller => "admin"
			return
		end

		ruta = params[:ruta]

		array = ruta.split(".")

		if array[array.length-1] == "xls"
			documento = Roo::Excel.new(ruta)
		elsif array[array.length-1] == "xlsx"
			documento = Roo::Excelx.new(ruta)
		elsif array[array.length-1] == "ods"
			documento = Roo::Openoffice.new(ruta)
		else
			flash[:errores] << "Disculpe, se espera una hoja de cálculo (.xls, .xlsx o .ods)."
			redirect_to :action => "agregar_asignatura", :controller => "admin"
			return
		end
				
		documento.default_sheet = documento.sheets.first

		#Se inicializa la primera celda (1,2)
		i = 0

		codigos = []
		nombres = []
		carreras = []
		unidades_credito = []
		requisitos = []
		tipos = []
		clasificaciones = []

		carreras_posibles = ["Biología", "Computación", "Geoquímica", "Física", "Matemática", "Química", "Complementaria"]
		tipos_posibles = ["Obligatoria","Electiva", "Obligatoria optativa", "Complementaria", "Otra"]
		clasificaciones_posibles = ["Semestre I", "Semestre II", "Semestre III", "Semestre IV", "Semestre V", 
													"Semestre VI", "Semestre VII", "Semestre VIII", "Semestre IX", "Semestre X"]

		
		#Este ciclo itera sobre todos los docentes de la lista, siempre y cuando las celdas respectivas no esté vacías
		2.upto(documento.last_row) do |line|
			#Se leen la primera fila: cedula, nombres, apellidos y correo.

			codigos[i] = documento.cell(line,'A')
			nombres[i] = documento.cell(line,'B')
			carreras[i] = documento.cell(line,'C')
			unidades_credito[i] = documento.cell(line,'D')
			requisitos[i] = documento.cell(line,'E')
			tipos[i] = documento.cell(line,'F')
			clasificaciones[i] = documento.cell(line,'G')

			fila = (line).to_s

			#Se validan los campos, cada una de estas validaciones son globales para los controladores,
			# por lo que se encuentran en application_controller.rb
			if codigos[i] == nil || codigos[i] == ""
				flash[:errores] << "Debe insertar el código de la fila #{fila}."
			else
				codigos[i] = codigos[i].to_s
				if __es_numero_flotante?(codigos[i])
					codigos[i] = codigos[i].to_i.to_s
				end

				if codigos[i].length < 4
					long = codigos[i].length
					for j in long..3 do
						codigos[i] = "0"+codigos[i]
					end
				end

				if !__es_codigo_de_asignatura?(codigos[i])
					flash[:errores] << "El código de la fila #{fila} debe estar conformado por cuatro (4) números."
				end
			end

			if nombres[i] == nil || nombres[i] == ""
				flash[:errores] << "Debe insertar el nombre de la fila #{fila}"
			end

			if carreras[i] == nil || carreras[i] == ""
				flash[:errores] << "Debe ingresar la carrera de la fila #{fila}."
			elsif !carreras_posibles.include?(carreras[i])
				aux = carreras[i].capitalize
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

				valido = false
				carreras_posibles.each do |nombre_carrera|
					if nombre_carrera.length == aux.length
						for j in 1..aux.length-1 do
							if aux[j] != nombre_carrera[j]
								if (aux[j] == "a" && nombre_carrera[j] == "á") ||
								 (aux[j] == "á" && nombre_carrera[j] == "a")
									aux[j] = nombre_carrera[j]
								end
								if (aux[j] == "e" && nombre_carrera[j] == "é") || 
									(aux[j] == "é" && nombre_carrera[j] == "e")
									aux[j] = nombre_carrera[j]
								end
								if (aux[j] == "i" && nombre_carrera[j] == "í") || 
									(aux[j] == "í" && nombre_carrera[j] == "i")
									aux[j] = nombre_carrera[j]
								end
								if (aux[j] == "o" && nombre_carrera[j] == "ó") ||
								 (aux[j] == "ó" && nombre_carrera[j] == "o")
									aux[j] = nombre_carrera[j]
								end
								if (aux[j] == "u" && nombre_carrera[j] == "ú") ||
								 (aux[j] == "ú" && nombre_carrera[j] == "u")
									aux[j] = nombre_carrera[j]
								end
							end
						end
						if aux == nombre_carrera
							carreras[i] = nombre_carrera
							valido = true
						end
					end
					break if valido
				end

				unless valido
					flash[:errores] << "Debe ingresar una carrera correcta en la fila #{fila}."
				end
			end



			if unidades_credito[i] == nil || unidades_credito[i] == ""
				flash[:errores] << "Debe insertar las unidades_credito de la fila #{fila}."
			else
				unidades_credito[i] = unidades_credito[i].to_s
				if __es_numero_flotante?(unidades_credito[i])
					unidades_credito[i] = unidades_credito[i].to_i.to_s
				end

				if !__es_numero_entero?(unidades_credito[i])
					flash[:errores] << "Las unidades de crédito de la fila #{fila} deben ser numéricas."
				end
			end

			
			if tipos[i] == nil || tipos[i] == ""
				flash[:errores] << "Debe ingresar el tipo de la fila #{fila}."
			elsif !tipos_posibles.include?(tipos[i])
				valido = false

				tipos_posibles.each do |tipo|
					if tipo.downcase == tipos[i].to_s.downcase
						tipos[i] = tipo
						valido = true
						break
					end
				end

				unless valido
					flash[:errores] << "Debe ingresar un tipo correcto en la fila #{fila}."
				end
			end


			if tipos[i] == "Obligatoria"
				if !clasificaciones_posibles.include?(clasificaciones[i])
					if __es_semestre_valido?(clasificaciones[i])
						clasificaciones[i] = __semestre_correspondiente(clasificaciones[i])
					else
						flash[:errores] << "Debe ingresar un semestre correcto en la fila #{fila}."
					end
				end
			elsif tipos[i] == "Electiva" || tipos[i] == "Obligatoria optativa"
				if clasificaciones[i] == nil || clasificaciones[i] == ""
					flash[:errores] << "Debe ingresar una mencion en la fila #{fila}."
				end
			end

			unless flash[:errores].length > 0
				#Si los datos son correctos, se verifica que no exista una asignatura con ese codigo
				if asignatura = Asignatura.where(:codigo => codigos[i]).first
					if Asignatura.where("id != ? AND nombre = ?",asignatura.id,nombres[i]).size > 0
						flash[:errores] << "Ya existe una asignatura en el sistema con el nombre de la fila #{fila}."
					end
				else
					if Asignatura.where(:nombre => nombres[i]).size > 0
						flash[:errores] << "Ya existe una asignatura en el sistema con el nombre de la fila #{fila}."
					end
				end
			end

			i += 1
			celda = documento.cell(i,1)
		end

		if codigos.length > 0
			unless flash[:errores].length > 0
				#Si los datos son correctos, se verifica que no exista una asignatura con ese codigo
				for i in 0..codigos.length-1 do
					unless asignatura = Asignatura.where(:codigo => codigos[i]).first
						asignatura = Asignatura.new
						asignatura.codigo = codigos[i]
					end

					asignatura.nombre = nombres[i]
					
					asignatura.unidades_credito = unidades_credito[i]

					asignatura.requisitos = requisitos[i]

					asignatura.tipo = tipos[i]

					if asignatura.save
						bitacora "Se guardó la asignatura #{asignatura.id} - #{asignatura.nombre} satisfactoriamente."

						#Se guardan las asignaturas carreras

						unless carrera_nueva = Carrera.where(:nombre => carreras[i]).first
							carrera_nueva = Carrera.new
							carrera_nueva.nombre = carreras[i]
							if carrera_nueva.save
								bitacora "Se guardó la carrera #{carrera_nueva.id}."
							else
								bitacora "No se pudo crear la carrera #{carrera}"
								flash[:errores] << "No se pudo crear la carrera."
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

						#Segun el tipo se guardaran las clasificaciones o las menciones
						if tipos[i] == "Electiva" || tipos[i] == "Obligatoria optativa"

							
							#Se guardan las menciones que no existan en el 
							unless mencion_nueva = Mencion.where(:nombre => clasificaciones[i]).first
								mencion_nueva = Mencion.new
								mencion_nueva.nombre = clasificaciones[i]
								if mencion_nueva.save
									bitacora "Se guardó la mencion #{clasificaciones[i]} satisfactoriamente."
								else
									bitacora "No se pudo crear la mencion #{clasificaciones[i]}"
									flash[:errores] << "No se pudo crear la mencion #{clasificaciones[i]}."
								end
							end



							#Se guardar la relacion entre las menciones y carreras que no existan previamente
							carrera_id = Carrera.where(:nombre => carreras[i]).first.id
							unless mencion_carrera = MencionCarrera.where(:mencion_id => mencion_nueva.id, :carrera_id => carrera_id).first
								mencion_carrera = MencionCarrera.new
								mencion_carrera.carrera_id = carrera_id
								mencion_carrera.mencion_id = mencion_nueva.id
								if mencion_carrera.save
									bitacora "Se guardó la carrera mencion #{mencion_carrera.id} satisfactoriamente."
								else
									bitacora "No se pudo crear la carrera mencion #{carreras[i]} - #{mencion_nueva.nombre}"
									flash[:errores] << "No se pudo crear la carrera mencion."
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



							if asignatura_clasificacion = AsignaturaClasificacion.where(:asignatura_id => asignatura.id).first
								texto = "Se eliminó la asignatura clasificacion #{asignatura.nombre} - #{asignatura_clasificacion.clasificacion.nombre}"
								asignatura_clasificacion.destroy
								bitacora texto
							end

						else
							if tipos[i] == "Obligatoria"
								#Las asignaturas obligatorias se clasifican en semestres

								#Se guardan los semestres que no existan en BD
								unless clasificacion_nueva = Clasificacion.where(:nombre => clasificaciones[i]).first
									clasificacion_nueva = Clasificacion.new
									clasificacion_nueva.nombre = clasificaciones[i]
									if clasificacion_nueva.save
										bitacora "Se guardó la clasificacion #{clasificacion_nueva.id} satisfactoriamente."
									else
										bitacora "No se pudo crear la clasificacion #{clasificaciones[i]}"
										flash[:errores] << "No se pudo crear la clasificacion."
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
									bitacora "No se pudo crear la asignatura clasificacion con asignatura #{asignatura.id} y clasificacion #{clasificacion_nueva.id}"
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
					end
				end
			end

			unless flash[:errores].length > 0
				flash[:exito] = "Se guardaron todas las asignaturas exitosamente."
				redirect_to :action => "asignaturas", :controller => "admin"
				return
			end

		else
			flash[:errores] << "Parece que el archivo está vacío"
		end
		redirect_to :action => "agregar_asignatura", :controller => "admin"
	end

	#Método para subir la lista de estudiantes al sistema
  def procesar_subir_lista_estudiantes_seccion
    @errores = []
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    if __es_del_grupo_docente && params[:archivo] && params[:seccion_sitio_web] && params[:seccion_sitio_web][:id] && !params[:archivo].blank?
      #Se guarda el parámetro en la variable archivo
      archivo = params[:archivo]
      seccion_sitio_web_id = params[:seccion_sitio_web][:id]

      array = archivo.original_filename.split(".")
      ext = array[array.length-1]
      unless ext == "xls" || ext == "xlsx" || ext == "ods"
        @errores << "El archivo debe ser una hoja de cálculo (.xls, .xlsx o .ods)"
      end

      unless seccion_sitio_web_id && __es_numero_entero?(seccion_sitio_web_id) && SeccionSitioWeb.where(:id => seccion_sitio_web_id).size > 0
        @errores << "Parece que esta sección ya no existe"
      end

      unless @errores.size > 0
      	#Estas funciones guardan el archivo en la carpeta doc de la aplicación
        nombre_archivo = "lista_de_estudiantes_seccion"

        ruta = Rails.root.join("doc/listas", nombre_archivo+"."+ext).to_s
        File.open(ruta, "wb") do |file|
          file.write(archivo.read)
        end

				seccion_sitio_web = SeccionSitioWeb.find(seccion_sitio_web_id)

				case ext
				when "xls"
					documento = Roo::Excel.new(ruta)
				when "xlsx"
					documento = Roo::Excelx.new(ruta)
				when "ods"
					documento = Roo::Openoffice.new(ruta)
				end
										
				documento.default_sheet = documento.sheets.first

				#Se inicializa la primera celda (1,8)
				i = 0
				cedulas = []
				nombres = []
				apellidos = []
				correos = []

				8.upto(documento.last_row) do |line|
					#Se leen la primera fila: cedula, nombres, apellidos y correo.

					break if(documento.cell(line,'C') == nil && documento.cell(line,'D') == nil && documento.cell(line,'E') == nil)


					cedulas[i] = documento.cell(line,'C')
					nombres_apellidos = documento.cell(line,'D')
					correos[i] = documento.cell(line,'E')

					fila = (line).to_s

					if cedulas[i] == nil || cedulas[i] == ""
						@errores << "Debe insertar la cédula del estudiante de la fila #{fila}."
					else
						cedulas[i] = cedulas[i].to_s
						if __es_numero_flotante?(cedulas[i])
							cedulas[i] = cedulas[i].to_i.to_s
						end

						if !__es_numero_entero?(cedulas[i])
							@errores << "La cédula del estudiante de la fila #{fila} debe ser numérica."
						end
					end

					if nombres_apellidos == nil || nombres_apellidos == ""
						@errores << "Debe ingresar el nombre y apellido del estudiante de la fila #{fila}."
					end

					if correos[i] == nil || correos[i] == ""
						@errores << "Debe insertar lel correo del estudiante de la fila #{fila}."
					elsif !__es_correo?(correos[i])
						@errores << "El correo "+((correos[i])? ' '+correos[i] : '')+" del estudiante de la fila #{fila} no tiene un formato adecuado."
					end

					unless @errores.size > 0
						var = nombres_apellidos.split(" ")
						apellidos[i] = var[0]+" "+var[1]
						if var[2]
							if var[3]
								nombres[i] = var[2]+" "+var[3]
							else
								nombres[i] = var[2]
							end
						else
							apellidos[i] = var[0]
							nombres[i] = var[1]
						end

						if usuario = Usuario.where(:cedula => cedulas[i]).first
							if Usuario.where("id != ? AND correo = ?", usuario.id, correos[i]).size > 0
								@errores << "Ya existe un usuario en el sistema con el correo "+correos[i]
							end
						else
							if Usuario.where(:correo => correos[i]).size > 0
								@errores << "Ya existe un usuario en el sistema con el correo "+correos[i]
							end
						end
					end

					i += 1
				end

				if cedulas.size == 0 && @errores.size == 0
					@errores << "Parece que este archivo está vacío, revíselo e intente nuevamente."
				end

				unless @errores.size > 0

					for i in 0..cedulas.length-1 do

						ya_estaba = false
						if Usuario.where(:cedula => cedulas[i]).size > 0
							usuario = Usuario.where(:cedula => cedulas[i]).first
							ya_estaba = true
						else
							usuario = Usuario.new
							usuario.cedula = cedulas[i]
						end

						usuario.nombre = nombres[i]
						usuario.apellido = apellidos[i]
						usuario.correo = correos[i]
						usuario.save

						Mailer.registro_de_usuario(usuario) unless ya_estaba

						bitacora "Se guardo al usuario #{usuario.descripcion}"
						
						unless estudiante = Estudiante.where(:id => usuario.id).first
							estudiante = Estudiante.new
							estudiante.id = usuario.id
							estudiante.save
							bitacora "Se guardo al estudiante #{usuario.descripcion}"
						end

						unless EstudianteSeccionSitioWeb.where(:estudiante_id => estudiante.id, :seccion_sitio_web_id => seccion_sitio_web.id).first
							estudiante_seccion_sitio_web = EstudianteSeccionSitioWeb.new
							estudiante_seccion_sitio_web.estudiante_id = estudiante.id
							estudiante_seccion_sitio_web.seccion_sitio_web_id = seccion_sitio_web.id
							estudiante_seccion_sitio_web.save
							Mailer.notificar_se_agrego_a_sitio_Web(usuario,sitio_web)
							bitacora "Se agrego al estudiante #{usuario.descripcion} a la seccion #{seccion_sitio_web.seccion.nombre} del sitio web de la asignatura #{params[:asignatura_nombre]} para el semestre #{params[:semestre]}"
						end
					end

					success = "ok"
				end
			end
    else
      @errores << "Debe seleccionar la lista de estudiantes"
    end
      	
    if success == "ok"
      redirect_to :action => "index", :controller => "estudiantes", :asignatura_nombre => sitio_web.nombre_url, :semestre => sitio_web.periodo
    else
    	flash[:errores] = @errores
      bitacora "Intento fallido de subida de lista de estudiantes a la seccion #{params[:seccion_sitio_web_id]}"
      redirect_to :back
    end
	end

end
