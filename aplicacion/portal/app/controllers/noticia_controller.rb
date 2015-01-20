# -*- encoding : utf-8 -*-
class NoticiaController < ApplicationController

layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_crear]

  def index
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "noticia"
    @es_del_grupo_docente = __es_del_grupo_docente
    
  end

  def crear
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "noticia"
    @es_del_grupo_docente = __es_del_grupo_docente
  end

  def procesar_crear
    errores = ""
    success = ""
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    if __es_del_grupo_docente      
      
      titulo = params[:titulo]
      noticia = params[:noticia]

      if titulo == nil || titulo == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El título de la noticia no puede estar vacío."}'
      end

      if noticia == nil || noticia == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La noticia no puede estar vacía."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      notice = Notice.new
      notice.titulo = params[:titulo]
      notice.noticia = params[:noticia]
      notice.sitio_web_id = @sitio_web.id
      notice.usuario_id = session[:usuario].id
      notice.save
      if notice.save
        success = "ok"
        bitacora "Se guardo la noticia #{notice.id}"
      else
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Disculpe, pero no se pudo guardar la noticia. Inténtelo nuevamente."}'
      end
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
      Mailer.notificar_noticia_a_estudiantes(@sitio_web.correos_estudiantes,@sitio_web,notice)
      flash[:exito] = "Se ha agregado la noticia exitosamente."
    else
      bitacora "Intento fallido de creación de noticia"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar_noticia
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    if params[:id] && __es_numero_entero?(params[:id]) && Notice.where(:id => params[:id]).size > 0
    
      noticia = Notice.find(params[:id])
      texto = "Se eliminó la noticia del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      noticia.destroy
      bitacora texto
      flash[:exito] = "Se eliminó la noticia exitosamente."
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "noticia", :action => "index"
      return
    else
      bitacora "Intento fallido de eliminar la noticia de id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      flash[:error] = "Disculpe, no se pudo eliminar la noticia. Inténtelo nuevamente."
      redirect_to :back
      return
    end 

  end

  def noticias
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @seccion = "noticia"
    @es_del_grupo_docente = __es_del_grupo_docente
    id_noticia = params[:id]

    if id_noticia && __es_numero_entero?(id_noticia) && Notice.where(:id => id_noticia).size > 0 
      @noticia = Notice.where(:id => id_noticia).first
      return
    end
    redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "noticia", :action => "index"
  end 
end
