# -*- encoding : utf-8 -*-

require 'zip/zip'


class EntregaController < ApplicationController

  layout "sitio_web"

  before_filter "verificar_que_pertenece_al_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_agregar_entrega, :procesar_editar_entrega]

  def index
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "entregas"
  end

  def agregar
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "entregas"
    @evaluaciones = @sitio_web.evaluacion

    if !__es_del_grupo_docente
      redirect_to :action => "index", :controller => "informacion_general", :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo
      return
    end
  end

  def procesar_agregar_entrega
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    errores = ""
    success = ""
    
    if __es_del_grupo_docente

      nombre = params[:nombre]
      fecha_entrega = params[:fecha_entrega]

      if nombre == nil || nombre == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar el nombre de la entrega."}'
      end

      if fecha_entrega == nil || fecha_entrega == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar la fecha de entrega."}'
      elsif !__fecha_valida?(fecha_entrega)
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha a ingresar debe tener el formato dd/mm/aaaa."}'
      end

      if __fecha_valida?(fecha_entrega)
        hoy = Time.now

        f1 = hoy.strftime("%d/%m/%Y").split("/")
        f2 = fecha_entrega.split("/")

        if DateTime.new(f2[2].to_i, f2[1].to_i, f2[0].to_i, 0, 0, 0) < DateTime.new(f1[2].to_i, f1[1].to_i, f1[0].to_i, 0, 0, 0)
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha de entrega no puede haber finalizado ya."}'
        end
      end

      unless errores.length > 0

        fecha_array = fecha_entrega.split("/")
        fecha_entrega = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

        entrega = Entrega.new
        entrega.sitio_web_id = sitio_web.id
        entrega.nombre = nombre
        entrega.fecha_entrega = fecha_entrega
        
        if entrega.save
          success = "ok"
          flash[:exito] = "Se ha agregado la entrega exitosamente."
          Mailer.notificar_se_creo_entrega(sitio_web.correos_estudiantes, session[:usuario], sitio_web, entrega)
          bitacora "Se creó la entrega #{entrega.id} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        else
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero no se pudo guardar la entrega. Inténtelo nuevamente."}'
        end
      end
    else
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, usted no tiene autorización para realizar esta acción."}'
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de creación de entrega"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def editar
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "entregas"

    if !__es_del_grupo_docente
      redirect_to :action => "index", :controller => "informacion_general", :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo
      return
    end

    if params[:id] && __es_numero_entero?(params[:id]) && Entrega.where(:id => params[:id]).size > 0
      @entrega = Entrega.find(params[:id])
      return
    end

    flash[:error] = "Parece que esta entrega no existe ya en el sistema."
  end

  def procesar_editar_entrega
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    errores = ""
    success = ""
    
    if __es_del_grupo_docente

      if params[:id] && params[:id] && Entrega.where(:id => params[:id]).size > 0
        
        entrega = Entrega.find(params[:id])
        
        nombre = params[:nombre]
        fecha_entrega = params[:fecha_entrega]

        if nombre == nil || nombre == ""
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar el nombre de la entrega."}'
        end

        if fecha_entrega == nil || fecha_entrega == ""
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar la fecha de entrega."}'
        elsif !__fecha_valida?(fecha_entrega)
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha a ingresar debe tener el formato dd/mm/aaaa."}'
        end

        if __fecha_valida?(fecha_entrega)
          hoy = Time.now

          f1 = hoy.strftime("%d/%m/%Y").split("/")
          f2 = fecha_entrega.split("/")

          if DateTime.new(f2[2].to_i, f2[1].to_i, f2[0].to_i, 0, 0, 0) < DateTime.new(f1[2].to_i, f1[1].to_i, f1[0].to_i, 0, 0, 0)
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha de entrega no puede haber finalizado ya."}'
          end
        end

        unless errores.length > 0
          unless entrega.fecha_entrega.strftime("%d/%m/%Y") == fecha_entrega
            bitacora_sitio_web "Modificó la fecha de la entrega #{entrega.nombre} de #{entrega.fecha_entrega.strftime('%d/%m/%Y')} a #{fecha_entrega}", sitio_web.id
          end

          fecha_array = fecha_entrega.split("/")
          fecha_entrega = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

          entrega.nombre = nombre
          entrega.fecha_entrega = fecha_entrega
          
          if entrega.save
            success = "ok"
            flash[:exito] = "Se ha editado la entrega exitosamente."
            Mailer.notificar_se_edito_entrega(sitio_web.correos_estudiantes, session[:usuario], sitio_web, entrega)
            bitacora "Se editó la entrega #{entrega.id} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
          else
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero no se pudo guardar la entrega. Inténtelo nuevamente."}'
          end
        end
      else
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que esta entrega no existe ya en el sistema."}'
      end
    else
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, usted no tiene autorización para realizar esta acción."}'
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de edición de entrega"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def ver_entrega
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    @es_estudiante_del_sitio_web = false
    @es_estudiante_del_sitio_web = @sitio_web.es_estudiante_del_sitio_web?(session[:usuario].id) if session[:usuario] 

    @entregable = nil

    @seccion = "entregas"

    if params[:id] && __es_numero_entero?(params[:id]) && Entrega.where(:id => params[:id]).first
      @entrega = Entrega.where(:id => params[:id]).first
      if @es_estudiante_del_sitio_web
        if Entregable.where(:estudiante_id => session[:usuario].id, :entrega_id => @entrega.id).size > 0
          @entregable = Entregable.where(:estudiante_id => session[:usuario].id, :entrega_id => @entrega.id).first
        end
      end
      return
    end

    redirect_to :action => "index", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
  end

  def eliminar
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente && params[:id] && __es_numero_entero?(params[:id]) && Entrega.where(:id => params[:id]).first
      entrega = Entrega.where(:id => params[:id]).first
      texto = "Se eliminó la entrega #{entrega.nombre}."
      evento_id = entrega.evento_id
      entrega.destroy
      bitacora texto
      flash[:exito] = "Se eliminó la entrega satisfactoriamente."

      if evento = Evento.where(:id => evento_id).first
        evento.destroy
      end
    else
      flash[:error] = "No se pudo eliminar la entrega. Inténtelo nuevamente."
      bitacora "Intento fallido de eliminación de entrega con id #{params[:id]}"
    end

    redirect_to :action => "index", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
  end

  def subir_entregable
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    #Se verifica que se mandó el archivo en el formulario
    if session[:usuario] && sitio_web.es_estudiante_del_sitio_web?(session[:usuario].id)
      estudiante = Estudiante.where(:id => session[:usuario].id).first

      if params[:entrega] && params[:entrega][:id] && __es_numero_entero?(params[:entrega][:id]) && Entrega.where(:id => params[:entrega][:id]).size > 0
        entrega = Entrega.where(:id => params[:entrega][:id]).first

        if entrega.finalizo?
          flash[:error] = "La fecha de entrega ya finalizó."
          redirect_to :id => entrega.id, :action => "ver_entrega", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
        else
          if params[:entregable] && (not params[:entregable].blank?)
            archivo = params[:entregable]

            directorio = Rails.root.join('doc', sitio_web.nombre_url).to_s
            unless File.exist? directorio
              FileUtils.mkdir directorio
            end

            directorio = Rails.root.join(directorio, sitio_web.periodo).to_s
            unless File.exist? directorio
              FileUtils.mkdir directorio
            end

            directorio = Rails.root.join(directorio, 'entregas').to_s
            unless File.exist? directorio
              FileUtils.mkdir directorio
            end

            directorio = Rails.root.join(directorio, entrega.nombre).to_s
            unless File.exist? directorio
              FileUtils.mkdir directorio
            end

            seccion_nombre = Seccion.where(:id => 
                SeccionSitioWeb.where(:sitio_web_id => sitio_web.id, :id => 
                  EstudianteSeccionSitioWeb.where(:estudiante_id => estudiante.id).collect{|x| x.seccion_sitio_web_id}
                ).collect{|x| x.seccion_id}
              ).first.nombre

            directorio = Rails.root.join(directorio, seccion_nombre).to_s
            unless File.exist? directorio
              FileUtils.mkdir directorio
            end

            array = archivo.original_filename.split(".")
            ext = array[array.length-1]

            if entrega.nombre.length > 20
              nombre_archivo = "Entrega_"+entrega.id.to_s+"_"
            else
              nombre_archivo = entrega.nombre.gsub("/", "").gsub(":", "").gsub(" ", "_") + "_"
            end

            nombre_archivo += estudiante.usuario.cedula.to_s+"_"+estudiante.usuario.nombre.split(" ")[0]+"_"+estudiante.usuario.apellido.split(" ")[0]+"."+ext

            ruta = Rails.root.join(directorio, nombre_archivo).to_s

            if File.exist? ruta
              FileUtils.rm ruta
            end

            File.open(ruta, 'wb') do |file|
              file.write(archivo.read)
            end

            unless entregable = Entregable.where(:entrega_id => entrega.id, :estudiante_id => estudiante.id).first
              entregable = Entregable.new
              entregable.entrega_id = entrega.id
              entregable.estudiante_id = estudiante.id              
            end

            entregable.nombre_original = archivo.original_filename

            entregable.url = ruta

            entregable.nombre = nombre_archivo

            entregable.tamano = archivo.size

            entregable.ext = ext

            if entregable.save
              flash[:exito] = "Se subió el archivo satisfactoriamente."
              bitacora "Se subió el entregable del estudiante  #{estudiante.usuario.descripcion} para la entrega #{entrega.nombre}"
              redirect_to :action => "index", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
              return
            else
              flash[:error] = "Parece que no se pudo subir el archivo. Inténtelo nuevamente."
            end
          else
            flash[:error] = "Debe seleccionar un archivo."
            redirect_to :id => entrega.id, :action => "ver_entrega", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
          end
        end
      else
        flash[:error] = "Parece que esta entrega ya no existe."
      end
    else
      flash[:error] = "No tiene autorización para realizar esta acción."
    end
    
    bitacora "Intento fallido de subida de un entregable"
    redirect_to :action => "index", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
    return
  end

  def eliminar_entregable
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if params[:id] && __es_numero_entero?(params[:id]) && Entregable.where(:id => params[:id]).first
      entregable = Entregable.where(:id => params[:id]).first

      entrega_id = entregable.entrega.id

      if session[:usuario] && session[:usuario].id == entregable.estudiante.id
        texto = "Se eliminó el entregable #{entregable.nombre}."
        entregable.destroy
        bitacora texto
        flash[:exito] = "Se eliminó el entregable satisfactoriamente."
      else
        flash[:error] = "Usted no tiene autorización para eliminar este entregable."
        bitacora "Intento fallido de eliminación de entregable."
      end

      redirect_to :id => entrega_id, :action => "ver_entrega", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
      return
    else
      flash[:error] = "No se pudo eliminar la entrega. Inténtelo nuevamente."
      bitacora "Intento fallido de eliminación de entrega con id #{params[:id]}"
      redirect_to :action => "index", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
    end
  end

  def descargar_entregable
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if params[:id] && __es_numero_entero?(params[:id]) && Entregable.where(:id => params[:id]).size > 0
      entregable = Entregable.find(params[:id])
      if File.exist? entregable.url
        send_file entregable.url, :filename => entregable.nombre
        return
      else
        flash[:error] = "Parece que este archivo ha sido borrado del servidor."
      end
    else
      flash[:error] = "No se pudo descargar el entregable. Inténtelo nuevamente."
    end

    redirect_to :action => "index", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
  end

  def descargar_entregables
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if params[:id] && __es_numero_entero?(params[:id]) && Entrega.where(:id => params[:id]).size > 0
      
      entrega = Entrega.find(params[:id])
      seccion = Seccion.where(:nombre => params[:seccion]).first

      if entrega.tiene_entregables?
        if File.exist? entrega.ruta
          estudiantes = []
          valido = true
          entrega.entregable.each do |entregable|
            unless File.exist? entregable.url
              estudiantes << entregable.estudiante.usuario.nombre_y_apellido
            end
          end

          if estudiantes.length == 0

            nombre_archivo = entrega.ruta + "/" + entrega.nombre.to_s + ".zip"
            #Rails.root.join('doc/'+sitio_web.nombre_url+"/"+sitio_web.periodo,'entregas').to_s

            Zip::ZipFile.open(nombre_archivo, Zip::ZipFile::CREATE) do |zipfile|
              entrega.entregable.each_with_index do |entregable, index|
                zipfile.remove(entregable.seccion+"/"+entregable.try(:nombre)) if zipfile.find_entry(entregable.seccion+"/"+entregable.try(:nombre))

                zipfile.add(entregable.seccion+"/"+entregable.try(:nombre), entregable.try(:url))
              end
            end

            send_file nombre_archivo

            return
          else
            if estudiantes.length == 1
              flash[:error] = "El entregable " + estudiantes[0] + " ha sido borrado del servidor."
            else
              estudiantes_array = "Los entregables de: "
              estudiantes.each_with_index do |estudiante, index|
                if index == 0
                  estudiantes_array += estudiante
                elsif index == estudiantes.length-1
                  estudiantes_array += " y " + estudiante
                else
                  estudiantes_array += ", " + estudiante
                end
              end
              
              flash[:error] = estudiantes_array + " han sido borrados del servidor."
            end
          end
          
        else
          flash[:error] = "Parece que esta carpeta ha sido borrada del servidor."
        end
      else
        flash[:error] = "Esta entrega no tiene ningún entregable todavía."
      end
      redirect_to :id => entrega.id, :action => "ver_entrega", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
    else
      flash[:error] = "No se pudieron descargar los entregables. Inténtelo nuevamente."
      redirect_to :action => "index", :controller => "entrega", :semestre => sitio_web.periodo, :asignatura_nombre => sitio_web.nombre_url
    end
  end
end
