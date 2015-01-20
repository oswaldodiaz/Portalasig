# -*- encoding : utf-8 -*-
class BibliografiaController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_editar]

  def editar
    if __es_del_grupo_docente
      @seccion = "informacion_general"
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
      if params[:bibliografias]
        bibliografias = params[:bibliografias]
        bibliografias.each_with_index do |dato, i|
          bibliografia = JSON.parse(dato, nil);
          
          if bibliografia["autor"] == nil || bibliografia["autor"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar el autor de la bibliografía '+(i+1).to_s+'"}'
          end

          if bibliografia["titulo"] == nil || bibliografia["titulo"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar el titulo de la bibliografía '+(i+1).to_s+'"}'
          end

          if bibliografia["descripcion"] == nil || bibliografia["descripcion"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar la descripción de la bibliografía '+(i+1).to_s+'"}'
          end
        end
      else
        errores = '{"error": "No se pudo guardar ninguna bibliografía."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      sitio_web.bibliography.each do |bibliography|
        bibliography.destroy
      end
      
      bibliografias.each_with_index do |dato, i|
        bibliografia = JSON.parse(dato, nil);
        
        bibliography = Bibliography.new
        bibliography.autores = bibliografia["autor"]
        bibliography.titulo = bibliografia["titulo"]
        bibliography.descripcion = bibliografia["descripcion"]
        bibliography.sitio_web_id = sitio_web.id
        if bibliography.save
          bitacora "Se guardó la bibliografía #{bibliography.id} del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        else
          errores = '{"error": "Parece que hubo un error y no se pudieron guardar los datos."}'
        end
      end
      success = "ok"
      flash[:exito] = "Se guardaron los objetivos de la asignatura satisfactoriamente."
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de bibliografía en el sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    if __es_del_grupo_docente
      if params[:id] && __es_numero_entero?(params[:id]) && Bibliography.where(:id => params[:id]).size > 0
        bibliografia = Bibliography.find(params[:id])
        texto = "Se eliminó la bibliografía de título: #{bibliografia.titulo} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        bibliografia.destroy
        bitacora texto
        flash[:exito] = "Se eliminó la bibliografia exitosamente."
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
        return
      else
        bitacora "Intento fallido de eliminar la bibliografía de id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        flash[:error] = "Disculpe, no se pudo eliminar la bibliografía. Inténtelo nuevamente."
        redirect_to :back
        return
      end
    else
      bitacora "Intento fallido de eliminar la bibliografía de id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]} por falta de autorización"
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end
  end
end
