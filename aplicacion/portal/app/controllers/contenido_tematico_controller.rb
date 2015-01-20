# -*- encoding : utf-8 -*-
class ContenidoTematicoController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_editar]
  
  def index
  	@seccion = "contenido_tematico"
		@es_del_grupo_docente = __es_del_grupo_docente
		@sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    unless __es_del_grupo_docente || @sitio_web.contenido_tematico.size > 0
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end
  end

  def editar
    if __es_del_grupo_docente
      @seccion = "contenido_tematico"
      @es_del_grupo_docente = __es_del_grupo_docente
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    else
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "grupo_docente", :action => "index"
      return
    end
  end

  def procesar_editar
    errores = ""
    success = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente 
      if params[:contenidos_tematicos]
        contenidos_tematicos = params[:contenidos_tematicos]
        contenidos_tematicos.each_with_index do |dato, i|
          contenido_tematico = JSON.parse(dato, nil);
          
          if contenido_tematico["titulo"] == nil || contenido_tematico["titulo"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el título del contenido temático '+(i+1).to_s+'"}'
          end

          if contenido_tematico["descripcion"] == nil || contenido_tematico["descripcion"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la descripción del contenido temático '+(i+1).to_s+'"}'
          end

        end
      else
        errores = '{"error": "No se pudo guardar ningún contenido temático."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      if sitio_web.contenido_tematico.size > 0
        sitio_web.contenido_tematico.each do |contenido_tematico|
          contenido_tematico.destroy
        end
      end

      contenidos_tematicos.each do |dato|
        contenido_tematico = JSON.parse(dato, nil);

        contenido = ContenidoTematico.new
        contenido.titulo = contenido_tematico["titulo"]
        contenido.descripcion = contenido_tematico["descripcion"]
        contenido.sitio_web_id = sitio_web.id
        
        if contenido.save
          bitacora "Se guardo el contenido tematico del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        else
          errores = '{"error": "Parece que hubo un error y no se pudieron guardar los datos."}'
        end
      end

      success = "ok"
      flash[:exito] = "Se guardó el contenido temático exitosamente."
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de contenido tematico del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    if __es_del_grupo_docente
      if params[:id] && __es_numero_entero?(params[:id]) && ContenidoTematico.where(:id => params[:id]).size > 0
        contenido = ContenidoTematico.find(params[:id])
        contenido.destroy
        flash[:exito] = "Se eliminó el tema exitosamente."
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "contenido_tematico", :action => "index"
        return
      else
        flash[:error] = "Disculpe, no se pudo eliminar el tema. Inténtelo nuevamente."
        redirect_to :back
        return
      end
    else
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "contenido_tematico", :action => "index"
      return
    end
  end
end


