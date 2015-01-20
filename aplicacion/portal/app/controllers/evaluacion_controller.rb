# -*- encoding : utf-8 -*-
class EvaluacionController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_editar]

  def index
    @seccion = "evaluacion"
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
  end

  def editar
    if __es_del_grupo_docente
      @seccion = "evaluacion"
      @es_del_grupo_docente = __es_del_grupo_docente
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      @tipos = ["Teoría","Práctica","Laboratorio","Otro"]
      @nombres = Evaluacion.order("nombre").where('nombre != "null"').collect{|x| x.nombre}.uniq

    else
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "evaluacion", :action => "index"
      return 
    end
  end 

  def procesar_editar
    errores = ""
    success = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente      
      if params[:evaluaciones]
        evaluaciones = params[:evaluaciones]
        evaluaciones.each_with_index do |dato, i|
          evaluacion = JSON.parse(dato, nil);
          
          if evaluacion["id"] == nil || evaluacion["id"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que la evaluación '+(i+1).to_s+' no es correcta"}'
          end

          if evaluacion["nombre"] == nil || evaluacion["nombre"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre de la evaluación '+(i+1).to_s+'"}'
          end

          if evaluacion["tipo"] == nil || evaluacion["tipo"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el tipo de la evaluación '+(i+1).to_s+'"}'
          end

          if evaluacion["valor"] == nil || evaluacion["valor"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el porcentaje de la evaluación '+(i+1).to_s+'"}'
          elsif !__es_numero_entero?(evaluacion["valor"]) && !__es_numero_flotante?(evaluacion["valor"])
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El porcentaje de la evaluación '+(i+1).to_s+' debe ser numérico"}'
          end

          if evaluacion["fecha_inicio"] != nil && evaluacion["fecha_inicio"] != "" && !__fecha_valida?(evaluacion["fecha_inicio"])
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha de inicio de la evaluación '+(i+1).to_s+' no tiene el formato adecuado dd/mm/yyyy."}'
          end

          if evaluacion["fecha_fin"] != nil && evaluacion["fecha_fin"] != "" && !__fecha_valida?(evaluacion["fecha_fin"])
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha fin de la evaluación '+(i+1).to_s+' no tiene el formato adecuado dd/mm/yyyy."}'
          end

          if __fecha_valida?(evaluacion["fecha_inicio"]) && __fecha_valida?(evaluacion["fecha_fin"])
            f1 = evaluacion["fecha_inicio"].split("/")
            f2 = evaluacion["fecha_fin"].split("/")

            if DateTime.new(f2[2].to_i, f2[1].to_i, f2[0].to_i, 0, 0, 0) < DateTime.new(f1[2].to_i, f1[1].to_i, f1[0].to_i, 0, 0, 0)
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La fecha fin de la evaluación '+(i+1).to_s+' no puede ser menor a la de inicio."}'
            end
          end

        end
      else
        errores = '{"error": "No se pudo guardar ninguna evaluación."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      if sitio_web.evaluacion.size > 0
        sitio_web.evaluacion.each do |evaluacion|
          esta = false
          evaluaciones.each do |dato|
            eval = JSON.parse(dato, nil);
            if eval["id"].to_i == evaluacion.id.to_i
              esta = true
              break
            end
          end

          if !esta
            titulo = evaluacion.nombre
            evaluacion.eliminar_evento
            evaluacion.destroy
            bitacora "Se eliminó la evaluación #{titulo} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
          end
        end
      end

      evaluaciones.each do |dato|
        evaluacion = JSON.parse(dato, nil);

        if evaluacion["id"] != "-1"
          evaluacion_nueva = Evaluacion.find(evaluacion["id"])
        else
          evaluacion_nueva = Evaluacion.new
          evaluacion_nueva.sitio_web_id = sitio_web.id
        end
        evaluacion_nueva.nombre = evaluacion["nombre"]
        evaluacion_nueva.tipo = evaluacion["tipo"]
        evaluacion_nueva.valor = evaluacion["valor"]
        evaluacion_nueva.fecha_inicio = evaluacion["fecha_inicio"]
        evaluacion_nueva.fecha_fin = evaluacion["fecha_fin"]
        
        if evaluacion_nueva.save
          evaluacion_nueva.guardar_evento
          bitacora "Se guardo la evaluacion #{evaluacion_nueva.id} del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        else
          errores = '{"error": "Parece que hubo un error y no se pudieron guardar los datos."}'
        end
      end

      success = "ok"
      flash[:exito] = "Se guardaron las evaluaciones exitosamente."
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de evaluaciones del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    if __es_del_grupo_docente
      if params[:id] && __es_numero_entero?(params[:id]) && Evaluacion.where(:id => params[:id]).size > 0
        evaluacion = Evaluacion.find(params[:id])

        evaluacion.eliminar_evento
        evaluacion.destroy
        flash[:exito] = "Se eliminó la evaluación exitosamente."
        bitacora "Se eliminó la evaluacion #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "evaluacion", :action => "index"
        return
      end      
    end

    flash[:error] = "Disculpe, no se pudo eliminar la evaluacion. Inténtelo nuevamente."
    bitacora = "Intento fallido de eliminación de evluacion del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]} con id #{params[:id]}"
    redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "evaluacion", :action => "index"
    return
  end

end
