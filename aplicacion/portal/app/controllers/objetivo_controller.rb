# -*- encoding : utf-8 -*-
class ObjetivoController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_editar]

  def editar
    if __es_del_grupo_docente
      @seccion = "informacion_general"
      @es_del_grupo_docente = __es_del_grupo_docente
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    else
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end
  end

  def procesar_editar
    errores = ""
    success = ""
    
    if __es_del_grupo_docente
      sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      if params[:objetivos]
        objetivos = params[:objetivos]
        objetivos.each_with_index do |objetivo, i|
          if objetivo == nil || objetivo == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar el objetivo '+(i+1).to_s+'."}'
          end
        end
      else
        errores = '{"error": "No se pudo guardar ningún objetivo."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      if sitio_web.objetivo.size > 0
        sitio_web.objetivo.each do |objetivo|
          objetivo.destroy
        end
      end

      objetivos.each_with_index do |obj, i|
        objetivo = Objetivo.new
        objetivo.descripcion = obj
        objetivo.sitio_web = sitio_web
        objetivo.save
        
        guardar_en_bitacora "el objetivo #{objetivo.id}", params[:asignatura_nombre], params[:semestre]
  
      end
      success = "ok"
      flash[:exito] = "Se guardaron los objetivos de la asignatura satisfactoriamente."
    end
    

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de objetivos en el sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    if __es_del_grupo_docente
      if params[:id] && __es_numero_entero?(params[:id]) && Objetivo.where(:id => params[:id]).size > 0
        objetivo = Objetivo.find(params[:id])
        texto = "Se eliminó el objetivo: #{objetivo.descripcion} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        objetivo.destroy
        bitacora texto
        flash[:exito] = "Se eliminó el objetivo exitosamente."
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
        return
      else
        bitacora "Intento fallido de eliminar el objetivo de id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        flash[:error] = "Disculpe, no se pudo eliminar el objetivo. Inténtelo nuevamente."
        redirect_to :back
        return
      end
    else
      bitacora "Intento fallido de eliminar el objetivo de id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]} por falta de autorización"
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end
  end
end
      