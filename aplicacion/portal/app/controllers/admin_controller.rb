# -*- encoding : utf-8 -*-
class AdminController < ApplicationController

	layout "inicio"

  before_filter :verificar_administrador_autenticado

  before_filter :es_ajax?, :only => [:procesar_agregar_asignatura, :procesar_editar_asignatura, :procesar_agregar_docente, :procesar_editar_docente, :procesar_agregar_estudiante, :procesar_editar_estudiante]

  ##################### ASIGNATURAS ########################

  #Vista donde se visualizan todos los asignatura
  def asignaturas
    @seccion = "Asignaturas"
    @titulo = "Asignaturas"
    if params[:orden]
      case params[:orden]
      when "Código"
        @orden = "codigo"
      when "Nombre"
        @orden = "nombre"
      when "Créditos"
        @orden = "unidades_credito"
      when "Tipo"
        @orden = "tipo"
      else
        @orden = "codigo"
      end
    else
      @orden = "codigo"
    end
    
    @carreras = ["Biología", "Computación", "Geoquímica", "Física", "Matemática", "Química", "Complementaria"]
    @categorias = ['Código', 'Nombre', 'Créditos','Tipo'] #Este es el orden que se mostrará en el select de la vista
    @categoria_seleccionada = params[:orden]

    @asignatura_datos = [] #En este arreglo se guardan los pares "Codigo - Nombre" de cada asignatura para mostrar en el campo de busqueda
    Asignatura.order('nombre').all.each do |asignatura|
      #En este foro se agregan uno a uno los valores de cada asignatura al arreglo de la manera indicada arriba
      @asignatura_datos << asignatura.codigo.to_s + " - " + asignatura.nombre.to_s
    end
  end

  #Vista que muestra los datos de un docente en específico
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
                  redirect_to :action => "editar_asignatura", :controller => "admin", :id => @asignatura.id.to_s
                  return
                end
              else
                flash[:error] = "Disculpe, estos datos no pertenecen a ninguna asignatura en el sistema. Inténtelo nuevamente"
                redirect_to :action => "asignaturas"
                return
              end
            end
          end
        end
      end
    end

    flash[:error] = "Disculpe, el formato de datos de la asignatura no es correcto. Inténtelo nuevamente."
    redirect_to :action => "asignaturas"
    return
  end

  #Vista donde se visualiza el formulario para crear una asignatura
  def agregar_asignatura
    @titulo = "Agregar asignatura"
    @seccion = "Asignaturas"
    @carreras = ["Biología", "Computación", "Geoquímica", "Física", "Matemática", "Química", "Complementaria"]
    @clasificaciones = ["Semestre I", "Semestre II", "Semestre III", "Semestre IV", "Semestre V", 
                        "Semestre VI", "Semestre VII", "Semestre VIII", "Semestre IX", "Semestre X"]
    @menciones = []

    @tipos = ["Obligatoria","Electiva", "Obligatoria optativa", "Complementaria", "Otra"]
    @a = __es_codigo_de_asignatura?("17744144")
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

    if success == "ok"
      bitacora "Intento fallido de agregacion de asignatura con código #{params[:codigo]}, nombre #{params[:nombre]}, carrera #{params[:carrera]}, unidades de crédito #{params[:unidades_credito]}, clasificacion #{params[:clasificacion]} y tipo #{params[:tipo]} del docente #{session[:usuario].descripcion}" if session[:usuario]
      render :json => JSON.parse('{"success":"ok"}')
    else
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def editar_asignatura
    if params[:id]
      id = params[:id]
      if __es_numero_entero?(id)
        if Asignatura.where(:id => id).size > 0
          #Si existe se busca al usuario
          @asignatura = Asignatura.find(id)

          @seccion = "Asignaturas"
          @titulo = "Editar asignatura"

          @carreras = ["Biología", "Computación", "Geoquímica", "Física", "Matemática", "Química", "Complementaria"]
          @clasificaciones = ["Semestre I", "Semestre II", "Semestre III", "Semestre IV", "Semestre V", 
                              "Semestre VI", "Semestre VII", "Semestre VIII", "Semestre IX", "Semestre X"]
          @menciones = Mencion.where(:id => 
                      MencionCarrera.where(:carrera_id => 
                        AsignaturaCarrera.where(:asignatura_id => @asignatura.id).collect{|x| x.carrera_id}
                      ).collect{|x| x.mencion_id}
                   ).collect{|x| x.nombre}
          @menciones << "Otra"

          @tipos = ["Obligatoria","Electiva", "Obligatoria optativa", "Complementaria", "Otra"]
          
          @asignatura_datos = [] #En este arreglo se guardan los pares "Codigo - Nombre" de cada asignatura para mostrar en el campo de busqueda
          Asignatura.order('nombre').all.each do |asignatura|
            #En este foro se agregan uno a uno los valores de cada asignatura al arreglo de la manera indicada arriba
            @asignatura_datos << asignatura.codigo.to_s + " - " + asignatura.nombre.to_s
          end
          
          return
        end
      end
    end
    flash[:error] = "Disculpe, no se pudo editar la asignatura. Inténtelo nuevamente."
    redirect_to :action => "asignaturas"
    return
  end

  def procesar_editar_asignatura
    errores = ""
    parametros = ""
    
    #Se guardan los parametros en variables locales para mejor manejo del sistema
    id = params[:id]
    codigo = params[:codigo]
    nombre = params[:nombre]
    carreras_dato = params[:carreras]
    uc = params[:unidades_credito]
    clasificacion = params[:clasificacion]
    tipo = params[:tipo]
    requisitos = params[:requisitos]
  
    #Se validan los campos, cada una de estas validaciones son globales para los controladores,
    # por lo que se encuentran en application_controller.rb
    if id && __es_numero_entero?(id) && Asignatura.where(:id => id).first

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
        unless asignatura = Asignatura.where(:id => id).first
          asignatura = Asignatura.new
          asignatura.codigo = codigo
        end
        #Si los datos son correctos, se verifica que no exista una asignatura con ese codigo
        if Asignatura.where("id != ? AND nombre = ?",asignatura.id,nombre).size > 0
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe una asignatura en el sistema con este nombre."}'
        end

        if Asignatura.where("id != ? AND codigo = ?",asignatura.id,codigo).size > 0
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe una asignatura en el sistema con este código."}'
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
            flash[:exito] = "Se editó la asignatura #{asignatura.nombre} satisfactoriamente."
          end
        end
      end

    else
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que esta asignatura ya no existe en el sistema."}'
    end


    if success == "ok"
      bitacora "Intento fallido de agregacion de asignatura con código #{params[:codigo]}, nombre #{params[:nombre]}, carrera #{params[:carrera]}, unidades de crédito #{params[:unidades_credito]}, clasificacion #{params[:clasificacion]} y tipo #{params[:tipo]} del docente #{session[:usuario].descripcion}" if session[:usuario]
      render :json => JSON.parse('{"success":"ok"}')
    else
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  #Eliminar una asignatura del sistema
  def eliminar_asignatura
    @seccion = "Asignaturas"
    #Primero se verifica que se enviaron datos a través de un formulario
    if params[:id]
      id = params[:id]
      #Se verifica que el id sea numérico
      if __es_numero_entero?(id)
        #Se verifica que el id pertenezca a una asignatura  del sistema
        if asignatura = Asignatura.where(:id => id).first
          #Si existe se elimina
          asignatura.destroy
          flash[:exito] = "Se eliminó la asignatura satisfactoriamente."
        else
          flash[:error] = "Disculpe, la asignatura especificada no existe en el sistema. Inténtelo nuevamente."
        end
      else
        flash[:error] = "Disculpe, la asignatura especificada no existe en el sistema. Inténtelo nuevamente."
      end
    else
      flash[:error] = "Disculpe, no se especificó una asignatura. Inténtelo nuevamente."
    end
    redirect_to :action => "asignaturas"
    return
  end

  #Eliminar docentes seleccionados en la vista docentes
  def eliminar_asignaturas
    @seccion = "Asignaturas"
    #Primero se verifica que se enviaron datos a través de un formulario
    #Para esto basta con probar que la variable params[:docentes] existe
    unless params[:asignaturas] && params[:id] && __es_numero_entero?(params[:id])
      flash[:error] = "Disculpe, no se especificó ninguna asignatura. Inténtelo nuevamente."
      redirect_to :action => "asignaturas"
      return
    end

    #Esta variable almacenara cuantos docentes (checkboxs) existian en el formulario
    car = params[:id].to_s
    cant = params[:asignaturas]["cantidad_"+car].to_i

    #se itera sobre cada posible docente eliminando el que haya sido seleccionado
    for i in 1..cant do
      #En rails solo los checkbox seleccionados son enviados por parametro al servidor, por lo que
      #si el parametro existe, entonces fue seleccionado y por ende debe ser eliminado
      if params["asignatura_check_box_"+car+"_"+i.to_s]
        id = params["asignatura_check_box_"+car+"_"+i.to_s]
        if asignatura = Asignatura.find(id)
          asignatura.destroy
        end
      end
    end

    flash[:exito] = "Se eliminaron las asignaturas seleccionados exitosamente."
    redirect_to :action => "asignaturas"
    return
  end


  #Método para subir la lista de asignaturas al sistema
  def procesar_subir_lista_asignaturas
    flash[:errores] = []
    @seccion = "Asignaturas"
    #Se verifica que se mandó el archivo en el formulario
    if params[:archivo] && (not params[:archivo].blank?)
      #Se guarda el parámetro en la variable archivo
      archivo = params[:archivo]

      array = archivo.original_filename.split(".")
      if array[array.length-1] == "xls" || array[array.length-1] == "xlsx" || array[array.length-1] == "ods"
        #Estas funciones guardan el archivo en la carpeta doc de la aplicación
        ruta = Rails.root.join('doc/listas', 'admin_lista_de_asignaturas_del_sistema.'+array[array.length-1]).to_s
        File.open(ruta, 'wb') do |file|
          file.write(archivo.read)
        end
        #bitacora "Se agegaron los estudiantes de la lista"
        redirect_to :action => "cargar_asignaturas", :controller => "archivo", :ruta => ruta
        return
      else
        flash[:errores] << "Disculpe, se espera una hoja de cálculo (.xls, .xlsx o .ods). Inténtelo nuevamente."
      end
    else
      flash[:errores] << "Debe subir la lista de asignaturas"
    end
    #bitacora "No se subio la lista de estudiantes"   
    redirect_to :action => "agregar_asignatura"
    return
  end

	
	##################### DOCENTES ########################

	#Vista donde se visualizan todos los docentes
	def docentes
		@seccion = "Docentes"
    @titulo = "Docentes"

    if Docente.all().size > 0
  		if params[:orden]
  			@orden = params[:orden]
  		else
  			@orden = "Cédula"
  		end

  		#Guardo todos los docentes
  		case @orden
  		when "Cédula"
  			@usuarios = Usuario.order('cedula').where(:id => Docente.all)
  		when "Nombre"
  			@usuarios = Usuario.order('nombre').where(:id => Docente.all)
  		when "Apellido"
  			@usuarios = Usuario.order('apellido').where(:id => Docente.all)
  		when "Correo"
  			@usuarios = Usuario.order('correo').where(:id => Docente.all)
  		end

    end
		
		  @categorias = ['Cédula', 'Nombre', 'Apellido', 'Correo'] #Este es el orden que se mostrará en el select de la vista

  		@docente_datos = [] #En este arreglo se guardan los pares "Cedula - Nombre Apellido" de cada usuario para mostrar en el campo de busqueda
  		Usuario.order('nombre').where(:id => Docente.all).each do |usuario|
  			#En este foro se agregan uno a uno los valores de cada docente al arreglo de la manera indicada arriba
  			@docente_datos << usuario.cedula.to_s + " - " + usuario.nombre_y_apellido.to_s
  		end
	end

	#Vista que muestra los datos de un docente en específico
	def docente
    id = params[:id]
    if id && id.gsub(/\s+/, "") && id.gsub(/\s+/, "").split("-").size > 0 && __es_numero_entero?(id.gsub(/\s+/, "").split("-")[0])
      cedula = id.gsub(/\s+/, "").split("-")[0]
      if Usuario.where(:cedula => cedula).size > 0 && Usuario.where(:cedula => cedula).first.es_docente?
        @usuario = Usuario.where(:cedula => cedula).first
        redirect_to :action => "editar_docente", :id => @usuario.id
        return
      else
        flash[:error] = "Disculpe, estos datos no pertenecen a ningún docente en el sistema. Inténtelo nuevamente"
      end
    end

    flash[:error] = "Disculpe, el formato de datos del docente no es correcto. Inténtelo nuevamente." unless flash[:error]
    redirect_to :action => "docentes"
    return
	end

	#Vista donde se visualiza el formulario para crear un docente
	def agregar_docente
		@seccion = "Docentes"
    @titulo = "Agregar docente"
	end

  #Método que guarda el estudiante en el sistema
  def procesar_agregar_docente
    errores = ""
    success = ""

    #Se guardan los parametros en variables locales para mejor manejo del sistema
    cedula = params[:cedula]
    nombre = params[:nombre]
    apellido = params[:apellido]
    correo = params[:correo]

    #Se validan los campos, cada una de estas validaciones son globales para los controladores,
    # por lo que se encuentran en application_controller.rb
    if cedula == nil || cedula == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la cédula"}'
    elsif !__es_numero_entero?(cedula)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula debe ser numérica."}'
    end

    if nombre == nil || nombre == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre"}'
    end

    if apellido == nil || apellido == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el apellido"}'
    end

    if correo == nil || correo == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el correo"}'
    elsif !__es_correo?(correo)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El correo no tiene el formato adecuado."}'
    end


    unless errores.length > 0
      #Si los datos son correctos, se verifica que exista un usuario valido
      if usuario = Usuario.where(:cedula => cedula).first
        if Usuario.where("id != ? AND correo = ?", usuario.id, correo).size > 0
          errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
        end
      else
        if Usuario.where(:correo => correo).size > 0
          errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
        else
          usuario = Usuario.new
          usuario.cedula = cedula
        end
      end
    end

    unless errores.length > 0
      usuario.nombre = nombre
      usuario.apellido = apellido
      usuario.correo = correo

      if usuario.save
        bitacora "Se ha guardado al usuario #{usuario.nombre_y_apellido}"
        Mailer.registro_de_usuario(usuario)

        #Una vez guardado el usuario se crea el estudiante que hereda el id de usuario y se guarda
        unless docente = Docente.where(:id => usuario.id).first
          docente = Docente.new
          docente.id = usuario.id
          docente.save
          bitacora "Se ha guardado al docente #{docente.usuario.nombre_y_apellido}"
        end

        #Se muestra el mensaje de exito
        success = "ok"
        flash[:exito] = "Se agregó el docente #{usuario.nombre} satisfactoriamente."
      end
    end

  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de docente con los datos #{params[:cedula]} #{params[:nombre]} #{params[:apellido]} #{params[:correo]} "
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

	def editar_docente
		@seccion = "Docentes"
    @titulo = "Editar docente"
		@docente_datos = [] #En este arreglo se guardan los pares "Cedula - Nombre Apellido" de cada usuario para mostrar en el campo de busqueda
		Usuario.order('nombre').where(:id => Docente.all).each do |usuario|
			#En este foro se agregan uno a uno los valores de cada docente al arreglo de la manera indicada arriba
			@docente_datos << usuario.cedula.to_s + " - " + usuario.nombre_y_apellido.to_s
		end
		if params[:id]
			id = params[:id]
			if __es_numero_entero?(id)
				if Docente.where(:id => id).size > 0
					#Si existe se busca al usuario
					@usuario = Usuario.find(id)
					return
				end
			end
		end
		flash[:error] = "Disculpe, no se pudo editar al docente. Inténtelo nuevamente."
		redirect_to :action => "docentes"
		return
	end

  #Método que editar un docente en el sistema
  def procesar_editar_docente
    errores = ""
    success = ""

    #Se guardan los parametros en variables locales para mejor manejo del sistema
    id = params[:id]
    cedula = params[:cedula]
    nombre = params[:nombre]
    apellido = params[:apellido]
    correo = params[:correo]

    #Se validan los campos, cada una de estas validaciones son globales para los controladores,
    # por lo que se encuentran en application_controller.rb
    if id == nil || id == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el id"}'
    elsif !__es_numero_entero?(id)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que el id del estudiante no es correcto."}'
    end

    if cedula == nil || cedula == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la cédula"}'
    elsif !__es_numero_entero?(cedula)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula debe ser numérica."}'
    end

    if nombre == nil || nombre == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre"}'
    end

    if apellido == nil || apellido == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el apellido"}'
    end

    if correo == nil || correo == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el correo"}'
    elsif !__es_correo?(correo)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El correo no tiene el formato adecuado."}'
    end


    if usuario = Usuario.where(:id => id).first
      if Usuario.where("id != ? AND cedula = ?",id,cedula).size > 0
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con esta cédula. '+id+' '+cedula+'"}'
      end

      if Usuario.where("id != ? AND correo = ?",id,correo).size > 0
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
      end
    else
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que este usuario ya no existe en el sistema."}'
    end

    unless errores.length > 0
      usuario.nombre = nombre
      usuario.apellido = apellido
      usuario.correo = correo

      if usuario.save
        bitacora "Se ha guardado al usuario #{usuario.nombre_y_apellido}"

        #Una vez guardado el usuario se crea el docente que hereda el id de usuario y se guarda
        unless docente = Docente.where(:id => usuario.id).first
          docente = Docente.new
          docente.id = usuario.id
          docente.save
          bitacora "Se ha guardado al docente #{docente.usuario.nombre_y_apellido}"
        end

        #Se muestra el mensaje de exito
        success = "ok"
        flash[:exito] = "Se editó el docente #{usuario.nombre} satisfactoriamente."
      end
    end

  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de edición de docente con los datos #{params[:id]} #{params[:cedula]} #{params[:nombre]} #{params[:apellido]} #{params[:correo]} "
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

	#Eliminar un docente del sistema
	def eliminar_docente
		@seccion = "Docentes"
		#Primero se verifica que se enviaron datos a través de un formulario
		if params[:id]
			id = params[:id]
			#Se verifica que el id sea numérico
			if __es_numero_entero?(id)
				#Se verifica que el id pertenezca a un docente del sistema
				if docente = Docente.where(:id => id).first
					#Si existe se elimina tanto el docente como el usuario, ya que los usurios sin rol no cumplen ningun papel en el sistema
					( (docente.usuario.tiene_mas_de_un_rol)? docente.destroy : docente.usuario.destroy)
					flash[:exito] = "Se eliminó al docente satisfactoriamente."
				else
					flash[:error] = "Disculpe, el docente especificado no existe en el sistema. Inténtelo nuevamente."
				end
			else
				flash[:error] = "Disculpe, el docente especificado no existe en el sistema. Inténtelo nuevamente."

			end
		else
			flash[:error] = "Disculpe, no se especificó un docente. Inténtelo nuevamente."
		end
		redirect_to :action => "docentes"
		return
	end

	#Eliminar docentes seleccionados en la vista docentes
	def eliminar_docentes
		@seccion = "Docentes"
		#Primero se verifica que se enviaron datos a través de un formulario
		#Para esto basta con probar que la variable params[:docentes] existe
		unless params[:docentes]
			flash[:error] = "Disculpe, no se especificó un docente. Inténtelo nuevamente."
			redirect_to :action => "docentes"
			return
		end

		#Esta variable almacenara cuantos docentes (checkboxs) existian en el formulario
		cant = params[:docentes][:cantidad].to_i

		#se itera sobre cada posible docente eliminando el que haya sido seleccionado
		for i in 1..cant do
			#En rails solo los checkbox seleccionados son enviados por parametro al servidor, por lo que
			#si el parametro existe, entonces fue seleccionado y por ende debe ser eliminado
			if params["docente_check_box_"+i.to_s]
				id = params["docente_check_box_"+i.to_s]
				docente = Docente.find(id)
				( (docente.usuario.tiene_mas_de_un_rol)? docente.destroy : docente.usuario.destroy)
			end
		end

		flash[:exito] = "Se eliminaron los docentes seleccionados exitosamente."
		redirect_to :action => "docentes"
		return
	end

	#Método para subir la lista de docentes al sistema
	def procesar_subir_lista_docentes
		#Se verifica que se mandó el archivo en el formulario
		if params[:archivo] && (not params[:archivo].blank?)
	    #Se guarda el parámetro en la variable archivo
	    archivo = params[:archivo]

			array = archivo.original_filename.split(".")
			if array[array.length-1] == "xls" || array[array.length-1] == "xlsx" || array[array.length-1] == "ods"
				#Estas funciones guardan el archivo en la carpeta doc de la aplicación
		    ruta = Rails.root.join('doc/listas', 'admin_lista_de_docentes_del_sistema.'+array[array.length-1]).to_s
		    File.open(ruta, 'wb') do |file|
		      file.write(archivo.read)
		    end
		    #bitacora "Se agegaron los estudiantes de la lista"
	    	redirect_to :action => "cargar_docentes", :controller => "archivo", :ruta => ruta
	    	return
	  	else
				flash[:error] = "Disculpe, se espera una hoja de cálculo (.xls, .xlsx o .ods). Inténtelo nuevamente."
			end
		else
			flash[:error] = "Debe subir la lista de docentes"
	  end
    #bitacora "No se subio la lista de estudiantes"		
		redirect_to :action => "agregar_docente"
		return
	end

	##################### ESTUDIANTES ########################

	#Vista donde se visualizan todos los estudiantes
	def estudiantes
		@seccion = "Estudiantes"
    @titulo = "Estudiantes"
		if params[:orden]
			@orden = params[:orden]
		else
			@orden = "Cédula"
		end

    #Guardo todos los estudiantes
    if Estudiante.all().size > 0
      case @orden
    	when "Cédula"
    		@usuarios = Usuario.order('cedula').where(:id => Estudiante.all)
    	when "Nombre"
    		@usuarios = Usuario.order('nombre').where(:id => Estudiante.all)
    	when "Apellido"
    		@usuarios = Usuario.order('apellido').where(:id => Estudiante.all)
    	when "Correo"
    		@usuarios = Usuario.order('correo').where(:id => Estudiante.all)
    	end
    end

		@categorias = ['Cédula', 'Nombre', 'Apellido', 'Correo'] #Este es el orden que se mostrará en el select de la vista

		@estudiante_datos = [] #En este arreglo se guardan los pares "Cedula - Nombre Apellido" de cada usuario para mostrar en el campo de busqueda
		Usuario.order('nombre').where(:id => Estudiante.all).each do |usuario|
			#En este foro se agregan uno a uno los valores de cada estudiante al arreglo de la manera indicada arriba
			@estudiante_datos << usuario.cedula.to_s + " - " + usuario.nombre_y_apellido.to_s
		end
	end

	#Vista que muestra los datos de un estudiante en específico
	def estudiante
		id = params[:id]
		if id && id.gsub(/\s+/, "") && id.gsub(/\s+/, "").split("-").size > 0 && __es_numero_entero?(id.gsub(/\s+/, "").split("-")[0])
      cedula = id.gsub(/\s+/, "").split("-")[0]
      if Usuario.where(:cedula => cedula).size > 0 && Usuario.where(:cedula => cedula).first.es_estudiante?
        @usuario = Usuario.where(:cedula => cedula).first
        redirect_to :action => "editar_estudiante", :id => @usuario.id
        return
      else
        flash[:error] = "Disculpe, estos datos no pertenecen a ningún docente en el sistema. Inténtelo nuevamente"
      end
    end

    flash[:error] = "Disculpe, el formato de datos del estudiante no es correcto. Inténtelo nuevamente." unless flash[:error]
		redirect_to :action => "estudiantes"
		return
	end

	#Vista donde se visualiza el formulario para crear un estudiante
	def agregar_estudiante
		@seccion = "Estudiantes"
    @titulo = "Agregar estudiante"
	end

	#Método que guarda el estudiante en el sistema
  def procesar_agregar_estudiante
    errores = ""
    success = ""

    #Se guardan los parametros en variables locales para mejor manejo del sistema
    cedula = params[:cedula]
    nombre = params[:nombre]
    apellido = params[:apellido]
    correo = params[:correo]

    #Se validan los campos, cada una de estas validaciones son globales para los controladores,
    # por lo que se encuentran en application_controller.rb
    if cedula == nil || cedula == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la cédula"}'
    elsif !__es_numero_entero?(cedula)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula debe ser numérica."}'
    end

    if nombre == nil || nombre == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre"}'
    end

    if apellido == nil || apellido == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el apellido"}'
    end

    if correo == nil || correo == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el correo"}'
    elsif !__es_correo?(correo)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El correo no tiene el formato adecuado."}'
    end


    unless errores.length > 0
      #Si los datos son correctos, se verifica que exista un usuario valido
      if usuario = Usuario.where(:cedula => cedula).first
        if Usuario.where("id != ? AND correo = ?", usuario.id, correo).size > 0
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
        end
      else
        if Usuario.where(:correo => correo).size > 0
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
        else
        	usuario = Usuario.new
          usuario.cedula = cedula
        end
      end
    end

    unless errores.length > 0
    	if Docente.where(:id => Usuario.where(:cedula => cedula).collect{|x| x.id}).size > 0
    		errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se puede agregar un docente como estudiante."}'
    	end
    end

    unless errores.length > 0
      usuario.nombre = nombre
      usuario.apellido = apellido
      usuario.correo = correo

      if usuario.save
        bitacora "Se ha guardado al usuario #{usuario.nombre_y_apellido}"
        Mailer.registro_de_usuario(usuario)

        #Una vez guardado el usuario se crea el estudiante que hereda el id de usuario y se guarda
        unless estudiante = Estudiante.where(:id => usuario.id).first
          estudiante = Estudiante.new
          estudiante.id = usuario.id
          estudiante.save
          bitacora "Se ha guardado al estudiante #{estudiante.usuario.nombre_y_apellido}"
        end

        #Se muestra el mensaje de exito
        success = "ok"
        flash[:exito] = "Se agregó el estudiante #{usuario.nombre} satisfactoriamente."
      end
    end

  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de studiante con los datos #{params[:cedula]} #{params[:nombre]} #{params[:apellido]} #{params[:correo]} "
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

	def editar_estudiante
		@seccion = "Estudiantes"
    @titulo = "Editar estudiante"
		@estudiante_datos = [] #En este arreglo se guardan los pares "Cedula - Nombre Apellido" de cada usuario para mostrar en el campo de busqueda
		Usuario.order('nombre').where(:id => Estudiante.all).each do |usuario|
			#En este foro se agregan uno a uno los valores de cada estudiante al arreglo de la manera indicada arriba
			@estudiante_datos << usuario.cedula.to_s + " - " + usuario.nombre_y_apellido.to_s
		end
		if params[:id]
			id = params[:id]
			if __es_numero_entero?(id)
				if Estudiante.where(:id => id).size > 0
					#Si existe se busca al usuario
					@usuario = Usuario.find(id)
					return
				end
			end
		end
		flash[:error] = "Disculpe, no se pudo editar al estudiante. Inténtelo nuevamente."
		redirect_to :action => "estudiantes"
		return
	end


  #Método que guarda el estudiante en el sistema
  def procesar_editar_estudiante
    errores = ""
    success = ""

    #Se guardan los parametros en variables locales para mejor manejo del sistema
    id = params[:id]
    cedula = params[:cedula]
    nombre = params[:nombre]
    apellido = params[:apellido]
    correo = params[:correo]

    #Se validan los campos, cada una de estas validaciones son globales para los controladores,
    # por lo que se encuentran en application_controller.rb
    if id == nil || id == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el id"}'
    elsif !__es_numero_entero?(id)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que el id del estudiante no es correcto."}'
    end

    if cedula == nil || cedula == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la cédula"}'
    elsif !__es_numero_entero?(cedula)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula debe ser numérica."}'
    end

    if nombre == nil || nombre == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre"}'
    end

    if apellido == nil || apellido == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el apellido"}'
    end

    if correo == nil || correo == ""
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el correo"}'
    elsif !__es_correo?(correo)
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El correo no tiene el formato adecuado."}'
    end



    if usuario = Usuario.where(:id => id).first
      if Usuario.where("id != ? AND cedula = ?",id,cedula).size > 0
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con esta cédula."}'
      end

      if Usuario.where("id != ? AND correo = ?",id,correo).size > 0
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
      end
    else
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que este usuario ya no existe en el sistema."}'
    end
      

    unless errores.length > 0
      if Docente.where(:id => id).size > 0
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"No se puede agregar un docente como estudiante."}'
      end
    end

    unless errores.length > 0
      usuario.nombre = nombre
      usuario.apellido = apellido
      usuario.correo = correo

      if usuario.save
        bitacora "Se ha guardado al usuario #{usuario.nombre_y_apellido}"


        #Una vez guardado el usuario se crea el estudiante que hereda el id de usuario y se guarda
        unless estudiante = Estudiante.where(:id => usuario.id).first
          estudiante = Estudiante.new
          estudiante.id = usuario.id
          estudiante.save
          bitacora "Se ha guardado al estudiante #{estudiante.usuario.nombre_y_apellido}"
        end

        #Se muestra el mensaje de exito
        success = "ok"
        flash[:exito] = "Se editó el estudiante #{usuario.nombre} satisfactoriamente."
      end
    end

  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de edición de estudiante con los datos #{params[:id]} #{params[:cedula]} #{params[:nombre]} #{params[:apellido]} #{params[:correo]} "
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end


	#Eliminar un estudiante del sistema
	def eliminar_estudiante
		@seccion = "Estudiantes"
		#Primero se verifica que se enviaron datos a través de un formulario
		if params[:id]
			id = params[:id]
			#Se verifica que el id sea numérico
			if __es_numero_entero?(id)
				#Se verifica que el id pertenezca a un docente del sistema
				if estudiante = Estudiante.where(:id => id).first
					#Si existe se elimina tanto el estudiante como el usuario, ya que los usurios sin rol no cumplen ningun papel en el sistema
					( (estudiante.usuario.tiene_mas_de_un_rol)? estudiante.destroy : estudiante.usuario.destroy)
					flash[:exito] = "Se eliminó al estudiante satisfactoriamente."
				else
					flash[:error] = "Disculpe, el estudiante especificado no existe en el sistema. Inténtelo nuevamente."
				end
			else
				flash[:error] = "Disculpe, el estudiante especificado no existe en el sistema. Inténtelo nuevamente."
			end
		else
			flash[:error] = "Disculpe, no se especificó un estudiante. Inténtelo nuevamente."
		end
		redirect_to :action => "estudiantes"
		return
	end

	#Eliminar estudiantes seleccionados en la vista estudiantes
	def eliminar_estudiantes
		@seccion = "Estudiantes"
		#Primero se verifica que se enviaron datos a través de un formulario
		#Para esto basta con probar que la variable params[:estudiantes] existe
		unless params[:estudiantes]
			flash[:error] = "Disculpe, no se especificó un estudiante. Inténtelo nuevamente."
			redirect_to :action => "estudiantes"
			return
		end

		#Esta variable almacenara cuantos estudiantes (checkboxs) existian en el formulario
		cant = params[:estudiantes][:cantidad].to_i

		#se itera sobre cada posible estudiante eliminando el que haya sido seleccionado
		for i in 1..cant do
			#En rails solo los checkbox seleccionados son enviados por parametro al servidor, por lo que
			#si el parametro existe, entonces fue seleccionado y por ende debe ser eliminado
			if params["estudiante_check_box_"+i.to_s]
				id = params["estudiante_check_box_"+i.to_s]
				estudiante = Estudiante.find(id)
				( (estudiante.usuario.tiene_mas_de_un_rol)? estudiante.destroy : estudiante.usuario.destroy)
			end
		end

		flash[:exito] = "Se eliminaron los estudiantes seleccionados exitosamente."
		redirect_to :action => "estudiantes"
		return
	end

	#Método para subir la lista de estudiantes al sistema
	def procesar_subir_lista_estudiantes
		@seccion = "Estudiantes"
		#Se verifica que se mandó el archivo en el formulario
		if params[:archivo] && (not params[:archivo].blank?)
	    #Se guarda el parámetro en la variable archivo
	    archivo = params[:archivo]

			array = archivo.original_filename.split(".")
			if array[array.length-1] == "xls" || array[array.length-1] == "xlsx" || array[array.length-1] == "ods"
				#Estas funciones guardan el archivo en la carpeta doc de la aplicación
		    ruta = Rails.root.join('doc/listas', 'admin_lista_de_estudiantes_del_sistema.'+array[array.length-1]).to_s
		    File.open(ruta, 'wb') do |file|
		      file.write(archivo.read)
		    end
		    #bitacora "Se agegaron los estudiantes de la lista"
	    	redirect_to :action => "cargar_estudiantes", :controller => "archivo", :ruta => ruta
	    	return
	  	else
				flash[:error] = "Disculpe, se espera una hoja de cálculo (.xls, .xlsx o .ods). Inténtelo nuevamente."
			end
		else
			flash[:error] = "Debe subir la lista de estudiantes"
	  end
    #bitacora "No se subio la lista de estudiantes"		
		redirect_to :action => "agregar_estudiante"
		return
	end
	
end