# -*- encoding : utf-8 -*-
class PlanificacionController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :except => [:index]

  def index  
    @seccion = "planificacion"
    @eventos = Evento.where(:sitio_web_id => @sitio_web.id).all

  end

  def crear_evento
    errores = ""
    success = ""
    id = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    if __es_del_grupo_docente
          
      #Se guardan los parametros en variables locales para mejor manejo del sistema
      fecha_inicio = params[:fecha_inicio]
      fecha_fin = params[:fecha_fin]
      titulo = params[:titulo]
      descripcion = params[:descripcion]

      if fecha_inicio == nil || fecha_inicio == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha de inicio del evento no puede estar vacía."}'
      elsif !__fecha_valida?(fecha_inicio)
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha de inicio del evento no tiene un formato adecuado."}'
      end

      if fecha_fin == nil || fecha_fin == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha fin del evento no puede estar vacía."}'
      elsif !__fecha_valida?(fecha_fin)
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha fin del evento no tiene un formato adecuado."}'
      end

      if __fecha_valida?(fecha_inicio) && __fecha_valida?(fecha_fin)
        f1 = fecha_inicio.split("/")
        f2 = fecha_fin.split("/")

        if DateTime.new(f2[2].to_i, f2[1].to_i, f2[0].to_i, 0, 0, 0) < DateTime.new(f1[2].to_i, f1[1].to_i, f1[0].to_i, 0, 0, 0)
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha fin no puede ser menor a la de inicio."}'
        end
      end

      if titulo == nil || titulo == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el título del evento."}'
      end


      unless errores.length > 0
        fecha_array = fecha_inicio.split("/")
        fecha_inicio = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

        fecha_array = fecha_fin.split("/")
        fecha_fin = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]
        
        evento = Evento.new
        evento.sitio_web_id = sitio_web.id
        evento.titulo = titulo
        evento.descripcion = descripcion
        evento.fecha_inicio = fecha_inicio
        evento.fecha_fin = fecha_fin
        
        if evento.save
          success = "ok"
          id = evento.id
          bitacora "Se creó correctamente el evento #{evento.id}"

        else
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que hubo un error y no se pudieron guardar los datos. Inténtelo nuevamente."}'
        end
      end
    else
      errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar esta acción.'
    end
  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok", "id":"'+id.to_s+'"}')
      Mailer.notificar_creacion_de_evento(sitio_web.correos_estudiantes,sitio_web,evento)
    else
      bitacora "Intento fallido de creacion de evento con fecha de inicio #{params[:fecha_inicio]}, fecha fin #{params[:fecha_fin]} titulo #{params[:titulo]}, descripcion #{params[:descripcion]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def editar_evento
    errores = ""
    success = ""
    id = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    if __es_del_grupo_docente
          
      #Se guardan los parametros en variables locales para mejor manejo del sistema
      id = params[:id]
      fecha_inicio = params[:fecha_inicio]
      fecha_fin = params[:fecha_fin]
      titulo = params[:titulo]
      descripcion = params[:descripcion]

      if __es_numero_entero?(id) && Evento.where(:id => id).size > 0
        if fecha_inicio == nil || fecha_inicio == ""
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la fecha de inicio del evento."}'
        elsif !__fecha_valida?(fecha_inicio)
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha de inicio del evento no tiene un formato adecuado."}'
        end

        if fecha_fin == nil || fecha_fin == ""
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la fecha fin del evento."}'
        elsif !__fecha_valida?(fecha_fin)
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha fin del evento no tiene un formato adecuado."}'
        end

        if __fecha_valida?(fecha_inicio) && __fecha_valida?(fecha_fin)
          f1 = fecha_inicio.split("/")
          f2 = fecha_fin.split("/")

          if DateTime.new(f2[2].to_i, f2[1].to_i, f2[0].to_i, 0, 0, 0) < DateTime.new(f1[2].to_i, f1[1].to_i, f1[0].to_i, 0, 0, 0)
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha fin no puede ser menor a la de inicio."}'
          end
        end

        if titulo == nil || titulo == ""
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el título del evento."}'
        end

        if descripcion == nil || descripcion == ""
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la descripción del evento."}'
        end

      else
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que este evento ya no existe en el sistema.'+id+'"}'
      end

      unless errores.length > 0
        fecha_array = fecha_inicio.split("/")
        fecha_inicio = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

        fecha_array = fecha_fin.split("/")
        fecha_fin = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]
        
        evento = Evento.find(id)
        evento.sitio_web_id = sitio_web.id
        evento.titulo = titulo
        evento.descripcion = descripcion
        evento.fecha_inicio = fecha_inicio
        evento.fecha_fin = fecha_fin
        
        if evento.save
          success = "ok"
          id = evento.id
          bitacora "Se editó correctamente el evento #{evento.id}"
          evento.guardar_evaluacion

          if evento.entrega
            if evento.entrega.fecha_entrega != evento.fecha_fin
              bitacora_sitio_web "Modificó la fecha de la entrega #{evento.entrega.nombre} de #{evento.entrega.fecha_entrega.strftime('%d/%m/%Y')} a #{evento.fecha_fin.strftime('%d/%m/%Y')}", sitio_web.id
            end
          end

          evento.guardar_entrega
        else
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que hubo un error y no se pudieron guardar los datos. Inténtelo nuevamente."}'
        end
      end
    else
      errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar esta acción.'
    end
  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok", "id":"'+id.to_s+'"}')
      Mailer.notificar_edicion_de_evento(sitio_web.correos_estudiantes,sitio_web,evento)
    else
      bitacora "Intento fallido de edicion de evento con id #{params[:id]}, fecha #{params[:fecha]}, titulo #{params[:titulo]}, descripcion #{params[:descripcion]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar_evento
    errores = ""
    success = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    if __es_del_grupo_docente
      id = params[:id]

      unless __es_numero_entero?(id) && Evento.where(:id => id).size > 0
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que este evento ya no existe en el sistema.'+id.to_s+'"}'
      end

      unless errores.length > 0
        evento = Evento.find(id)
        evento.eliminar_evaluacion
        if evento.destroy
          success = "ok"
          bitacora "Se eliminó correctamente el evento #{id}"
        else
          errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que hubo un error y no se pudieron guardar los datos. Inténtelo nuevamente."}'
        end
      end
    else
      errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar esta acción.'
    end
  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de eliminacion de evento con id #{params[:id]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def modificar_fecha_evento
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    response = JSON.parse('{"success":"error"}')
    if __es_del_grupo_docente
      if params[:id] && params[:fecha_inicio] && params[:fecha_fin] && 
        __es_numero_entero?(params[:id]) && __fecha_valida?(params[:fecha_inicio])
        __fecha_valida?(params[:fecha_fin]) && Evento.where(:id => params[:id]).size > 0
        
        evento = Evento.find(params[:id])

        fecha_array = params[:fecha_inicio].split("/")
        fecha_inicio = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]
        fecha_array = params[:fecha_fin].split("/")
        fecha_fin = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

        evento.fecha_inicio = fecha_inicio
        evento.fecha_fin = fecha_fin
        evento.save

        if evaluacion = Evaluacion.where(:evento_id => evento.id).first
          evaluacion.fecha_inicio = evento.fecha_inicio
          evaluacion.fecha_fin = evento.fecha_fin
          evaluacion.save
        end

        if evento.entrega
          if evento.entrega.fecha_entrega != evento.fecha_fin
            bitacora_sitio_web "Modificó la fecha de la entrega #{evento.entrega.nombre} de #{evento.entrega.fecha_entrega.strftime('%d/%m/%Y')} a #{evento.fecha_fin.strftime('%d/%m/%Y')}", sitio_web.id
          end
        end

        evento.guardar_entrega

        response = JSON.parse('{"success":"ok"}')
        Mailer.notificar_edicion_de_evento(sitio_web.correos_estudiantes,sitio_web,evento)
      end
    end
    render :json => response
  end
end

