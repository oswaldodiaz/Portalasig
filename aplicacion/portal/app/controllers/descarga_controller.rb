# -*- encoding : utf-8 -*-
class DescargaController < ApplicationController
  layout "sitio_web"

  before_filter ["verificar_sitio_web"]
  

  def index
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @tipos = ["Entregas", "Exámenes", "Guías", "Laboratorio", "Proyectos", "Taller", "Teoría", "Práctica", "Otros"]
    
    unless __es_del_grupo_docente || @sitio_web.archivo.size > 0
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end

    @seccion = "descargas"
    if session[:usuario]
      @pertenece_al_sitio_web = @sitio_web.pertenece_al_sitio_web?(session[:usuario].id)
    else
      @pertenece_al_sitio_web = false
    end

  end
 
  def agregar
    @seccion = "descargas"
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    @tipos = ["Entregas", "Exámenes", "Guías", "Laboratorio", "Proyectos", "Taller", "Teoría", "Práctica", "Otros"]

    unless __es_del_grupo_docente
      redirect_to :controller => "descarga", :action => "index", :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo
      return
    end
  end

  #Método para subir la lista de docentes al sistema
  def procesar_agregar
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    errores = []

    #Se verifica que se mandó el archivo en el formulario
    if __es_del_grupo_docente && params[:cantidad] && params[:cantidad][:archivos] && __es_numero_entero?(params[:cantidad][:archivos])

      cant = params[:cantidad][:archivos].to_i


      for i in 1..cant do
        unless params[:archivo]["nombre_"+i.to_s]
          errores << "Debe ingresar el nombre del archivo #{i.to_s}."
        end

        unless params[:archivo]["tipo_"+i.to_s]
          errores << "Debe ingresar el tipo del archivo #{i.to_s}."
        end

        unless params["archivo_a_subir_"+i.to_s] && (not params["archivo_a_subir_"+i.to_s].blank?)
          errores << "Debe ingresar el archivo del archivo #{i.to_s}."
        end
      end

      unless errores.length > 0

        for i in 1..cant do
          archivo = params["archivo_a_subir_"+i.to_s]

          directorio = Rails.root.join('doc', @sitio_web.nombre_url).to_s
          unless File.exist? directorio
            FileUtils.mkdir directorio
          end

          directorio = Rails.root.join(directorio, @sitio_web.periodo).to_s
          unless File.exist? directorio
            FileUtils.mkdir directorio
          end

          directorio = Rails.root.join(directorio, 'descargas').to_s
          unless File.exist? directorio
            FileUtils.mkdir directorio
          end

          ruta2 = Rails.root.join(directorio, archivo.original_filename).to_s

          array = archivo.original_filename.split(".")
          nombre = ""
          for j in 0..array.length-2 do 
            nombre += ((j > 0)? "." : "" ) + array[j]
          end
          ext = array[array.length-1]
          j = 1
          while File.exist? ruta2
            ruta2 = Rails.root.join(directorio, nombre + " ("+j.to_s+")."+ext).to_s
            j += 1
          end

          ruta = ruta2
          File.open(ruta, 'wb') do |file|
            file.write(archivo.read)
          end

          unless descarga = Archivo.where(:sitio_web_id => @sitio_web.id, :url => ruta).first
            descarga = Archivo.new
            descarga.url = ruta
            descarga.sitio_web_id = @sitio_web.id
          end

          descarga.nombre = params[:archivo]["nombre_"+i.to_s]

          descarga.tipo = params[:archivo]["tipo_"+i.to_s]

          descarga.tamano = archivo.size

          descarga.nombre_original = archivo.original_filename

          ext = archivo.original_filename.split(".")

          descarga.ext = ext[ext.length-1]

          if descarga.save
            Mailer.notificar_descarga_nueva(@sitio_web.correos, session[:usuario], @sitio_web, descarga)
            bitacora "Se subió el archivo #{descarga.nombre} en #{descarga.url}"
          else
            errores << "Parece que no se pudo subir el archivo #{i}. Inténtelo nuevamente."
          end
        end
      end
    else
      errores << "Parece que no se pudo subir su archivo. Inténtelo nuevamente."
    end
    

    unless errores.length > 0
      if cant > 1
        flash[:exito] = "Se subieron los archivos correctamente."
      else
        flash[:exito] = "Se subió el archivo correctamente."
      end
      redirect_to :action => "index", :controller => "descarga", :semestre => @sitio_web.periodo, :asignatura_nombre => @sitio_web.nombre_url
      return
    end    

    flash[:errores] = errores
    bitacora "Inteno fallido de subida de un archivo al sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
    redirect_to :controller => "descarga", :action => "agregar", :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo
    return
  end

  def descargar_archivo
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if params[:id] && __es_numero_entero?(params[:id]) && Archivo.where(:id => params[:id]).size > 0
      archivo = Archivo.find(params[:id])
      if File.exist? archivo.url
        send_file archivo.url, :filename => archivo.nombre_original
      else
        flash[:error] = "Parece que este archivo ha sido borrado del servidor."
      end
    else
      flash[:error] = "No se pudo descargar el archivo. Inténtelo nuevamente."
    end
  end

  def eliminar
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if params[:id] && __es_numero_entero?(params[:id]) && Archivo.where(:id => params[:id]).size > 0
      archivo = Archivo.find(params[:id])
      texto = "Se eliminó el archivo #{archivo.url} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      archivo.destroy
      bitacora texto
      flash[:exito] = "Se eliminó el archivo satisfactoriamente."
    else
      flash[:error] = "No se pudo eliminar el archivo. Inténtelo nuevamente."
      bitacora "No se pudo eliminar el archivo #{archivo.url} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
    end

    redirect_to :back
  end
end
