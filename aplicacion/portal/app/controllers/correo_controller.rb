# -*- encoding : utf-8 -*-
class CorreoController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:enviar]
  
  def index
    unless __es_del_grupo_docente
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end
    
    @seccion = "correo"
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @secciones_sitio_web = SeccionSitioWeb.where(:sitio_web_id => @sitio_web.id)
    @docentes = Usuario.where(:id => DocenteSitioWeb.where(:sitio_web_id => @sitio_web.id).collect{|x| x.docente_id})
    @preparadores = Usuario.where(:id => Preparador.where(:sitio_web_id => @sitio_web.id).collect{|x| x.estudiante_id})

  end

  def enviar
    errores = ""
    success = ""
    
    if __es_del_grupo_docente 
          
      #Se guardan los parametros en variables locales para mejor manejo del sistema
      correos = params[:correos]
      asunto = params[:asunto]
      texto = params[:texto]

      lista_correo = ""

      if correos == nil || correos == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar los correos."}'
      else
        correos.split(",").each do |correo|
          if !__es_correo? correo
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El correo '+correo+' no tiene un formato adecuado."}'
          else
            lista_correo += ((lista_correo.length > 0)? "," : "") + correo
          end
        end
      end

      if asunto == nil || asunto == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar asunto del correo."}'
      end

      if texto == nil || texto == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe ingresar un mensaje en el correo."}'
      end

      unless errores.length > 0
        Mailer.enviar_correo_nuevo(asunto, lista_correo, texto,session[:usuario].nombre_y_apellido)
        success = "ok"
      end

    else
      errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar esta acción. #{__es_del_grupo_docente} #{params[:id]} #{params[:codigo]} #{params[:nombre]} #{params[:clasificacion]} #{params[:requisitos]} #{params[:id]} #{params[:unidades_credito]}" }'
    end
  
    if success == "ok"
      flash[:exito] = "Se ha enviado el correo exitosamente."
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de envio de correo"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end
end
