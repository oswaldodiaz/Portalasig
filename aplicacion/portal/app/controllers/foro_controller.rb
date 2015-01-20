# -*- encoding : utf-8 -*-
class ForoController < ApplicationController
	layout "sitio_web"

	before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_crear, :agregar_comentario]

	def index
		@sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
		@seccion = "foro"
		@es_del_grupo_docente = __es_del_grupo_docente
    @pertenece_al_sitio_web = @sitio_web.pertenece_al_sitio_web?(session[:usuario].id) if session[:usuario]
    @es_estudiante_del_sitio_web = @sitio_web.es_estudiante_del_sitio_web?(session[:usuario].id) if session[:usuario]
	end

  def crear
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "foro"
    @es_del_grupo_docente = __es_del_grupo_docente
    @pertenece_al_sitio_web = @sitio_web.pertenece_al_sitio_web?(session[:usuario].id) if session[:usuario]

    unless @pertenece_al_sitio_web
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "foro", :action => "index"
    end
  end

  def procesar_crear
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    errores = ""
    success = ""
    
    if session[:usuario] && sitio_web.pertenece_al_sitio_web?(session[:usuario].id)

      titulo = params[:titulo]
      texto = params[:texto]

      if titulo == nil || titulo == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El titulo del foro no puede estar vacío."}'
      end

      if texto == nil || texto == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El contenido del foro no puede estar vacío."}'
      end

      unless errores.length > 0

        foro = Foro.new
        foro.usuario_id = session[:usuario].id
        foro.titulo = titulo
        foro.descripcion = texto
        foro.sitio_web_id = sitio_web.id
        
        if foro.save
          success = "ok"
          Mailer.notificar_foro_nuevo(sitio_web.correos,session[:usuario],sitio_web, foro)
          bitacora "Se creó el foro #{foro.id} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        else
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero no se pudo guardar el comentario. Inténtelo nuevamente."}'
        end
      end
    else
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, usted no tiene autorización para realizar esta acción."}'
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
      flash[:exito] = "Se ha agregado el comentario exitosamente."
    else
      bitacora "Intento fallido de creación de foro con titulo #{params[:titulo]} y texto #{params[:texto]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def foros
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "foro"
    @es_del_grupo_docente = __es_del_grupo_docente

    @pertenece_al_sitio_web = false
    @pertenece_al_sitio_web = @sitio_web.pertenece_al_sitio_web?(session[:usuario].id) if session[:usuario]

    @es_estudiante_del_sitio_web = false
    @es_estudiante_del_sitio_web = @sitio_web.es_estudiante_del_sitio_web?(session[:usuario].id) if session[:usuario]

    id_foro = params[:id]

    if id_foro && __es_numero_entero?(id_foro) && Foro.where(:id => id_foro).size > 0 
      @foro = Foro.where(:id => id_foro).first
      return
    end
    redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "foro", :action => "index"
  end 

  def agregar_comentario
    errores = ""
    success = ""
    id = params[:id]
    coment = params[:comentario]

    if id && coment && __es_numero_entero?(id) && Foro.where(:id => id).size > 0 && __es_string_valido?(coment)
        
      comentario = Comentario.new
      comentario.usuario_id = session[:usuario].id
      comentario.foro_id = id
      comentario.comentario = coment
      comentario.save
      success = "ok"
      bitacora "Se guardo el comentario #{comentario.id}"
      Mailer.notificar_comentario_nuevo(@sitio_web.correos,session[:usuario],@sitio_web, comentario)
     
    else
      errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero no se pudo guardar el comentario. Inténtelo nuevamente."}'
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
      flash[:exito] = "Se ha agregado el comentario exitosamente."
    else
      bitacora "Intento fallido de activación de usuario con id"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar_foro
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    if params[:id] && __es_numero_entero?(params[:id]) && Foro.where(:id => params[:id]).size > 0
    
      foro = Foro.find(params[:id])
      texto = "Se eliminó el objetivo: #{foro.descripcion} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      foro.destroy
      bitacora texto
      flash[:exito] = "Se eliminó el foro exitosamente."
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "foro", :action => "index"
      return
    else
      bitacora "Intento fallido de eliminar el foro de id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      flash[:error] = "Disculpe, no se pudo eliminar el foro. Inténtelo nuevamente."
      redirect_to :back
      return
    end 
  end


  def eliminar_comentario
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    id_comentario = params[:id]

    if id_comentario && __es_numero_entero?(id_comentario) && Comentario.where(:id => id_comentario).size > 0
    
      comentario = Comentario.find(params[:id])
      texto = "Se eliminó el comentario: #{comentario.comentario} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      id = comentario.foro.id 
      comentario.destroy
      bitacora texto
      flash[:exito] = "Se eliminó el comentario exitosamente."
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "foro", :action => "foros", :id => id
      return
    else
      bitacora "Intento fallido de eliminar el comentario de id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      flash[:error] = "Disculpe, no se pudo eliminar el comentario. Inténtelo nuevamente."
      redirect_to :back
      return
    end 
  end
end
