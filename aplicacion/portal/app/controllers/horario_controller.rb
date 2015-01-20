# -*- encoding : utf-8 -*-
class HorarioController < ApplicationController
layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_editar]

  def index
  	@seccion = "horarios"
		@es_del_grupo_docente = __es_del_grupo_docente
		@sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    
    unless __es_del_grupo_docente || @sitio_web.horario.size > 0
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "horario", :action => "index"
      return
    end
  end

  def editar
    if __es_del_grupo_docente
      @seccion = "horarios"
      @es_del_grupo_docente = __es_del_grupo_docente
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

      @dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves','Viernes', 'Sábado', 'Domingo']
      @tipos = ["Teoría", "Práctica", "Laboratorio", "Otros"]
      @horas = []
      ini = 7
      fin = 18
      for i in 0..(fin-ini) do
        @horas[i] = i+ini
      end
      @docentes = @sitio_web.docentes
      @preparadores = @sitio_web.preparadores

      
      @aulas = Horario.all().collect{|x| x.aula}.uniq
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
      if params[:horarios]
        horarios = params[:horarios]
        horarios.each_with_index do |dato, i|
          horario = JSON.parse(dato, nil);
          
          if horario["cargo"] != "docente" && horario["cargo"] != "preparador"
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El cargo del horario '+(i+1).to_s+' no es correcto."}'
          else

            if horario["usuario_id"] == nil || horario["usuario_id"] == ""
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que el '+horario["cargo"]+' del horario '+(i+1).to_s+' no existe."}'
            elsif !__es_numero_entero?(horario["usuario_id"])
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que el '+horario["cargo"]+' del horario '+(i+1).to_s+' no existe."}'
            else
              if (horario["cargo"] == "docente" && !(Docente.where(:id => horario["usuario_id"]).size > 0) ) ||
                  (horario["cargo"] == "preparador" && !(Estudiante.where(:id => horario["usuario_id"]).size > 0) )
                errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Parece que el '+horario["cargo"]+' del horario '+(i+1).to_s+' no existe."}'
              else

                nombre = Usuario.find(horario["usuario_id"]).nombre_y_apellido
              
                seccion = nil
                if horario["seccion"] == nil || horario["seccion"] == ""
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La sección del horario del '+horario["cargo"]+' '+nombre+' no puede estar vacía."}'
                elsif (horario["cargo"] == "docente" && !(DocenteSitioWeb.where(:docente_id => horario["usuario_id"], :sitio_web_id => sitio_web.id).size > 0) ) ||
                      (horario["cargo"] == "preparador" && !(Preparador.where(:estudiante_id => horario["usuario_id"], :sitio_web_id => sitio_web.id).size > 0) )
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El '+horario["cargo"]+' '+nombre+' no tiene ninguna sección asignada aún, diríjase a Grupo Docente y asígnele una sección."}'
                elsif !(seccion = Seccion.where(:nombre => horario["seccion"]).first)
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La sección del horario del '+horario["cargo"]+' '+nombre+' no existe."}'
                elsif (horario["cargo"] == "docente" && !(DocenteSitioWeb.where(:docente_id => horario["usuario_id"], :seccion_id => seccion.id, :sitio_web_id => sitio_web.id).size > 0) ) ||
                      (horario["cargo"] == "preparador" && !(Preparador.where(:estudiante_id => horario["usuario_id"], :seccion_id => seccion.id, :sitio_web_id => sitio_web.id).size > 0) )
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La sección del horario del '+horario["cargo"]+' '+nombre+' no pertenece al grupo docente."}'
                end

                if horario["dia"] == nil || horario["dia"] == ""
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El día del horario del '+horario["cargo"]+' '+nombre+' no puede estar vacío."}'
                end

                if horario["hora_inicio"] == nil || horario["hora_inicio"] == ""
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La hora de inicio del horario del '+horario["cargo"]+' '+nombre+' no puede estar vacía."}'
                end

                if horario["hora_fin"] == nil || horario["hora_fin"] == ""
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La hora fin del horario del '+horario["cargo"]+' '+nombre+' no puede estar vacío."}'
                end

                if horario["tipo"] == nil || horario["tipo"] == ""
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El tipo del horario del '+horario["cargo"]+' '+nombre+' no puede estar vacío."}'
                end

              end
            end
          end
        end
      else
        errores = '{"error": "No se pudo guardar ningún horario."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      if sitio_web.horario.size > 0
        sitio_web.horario.each do |horario|
          horario.destroy
        end
      end

      horarios.each do |dato|
        horario = JSON.parse(dato, nil);

        horario_nuevo = Horario.new
        horario_nuevo.sitio_web_id = sitio_web.id
        horario_nuevo.usuario_id = horario["usuario_id"]
        horario_nuevo.seccion_id = Seccion.where(:nombre => horario["seccion"]).first.id
        horario_nuevo.dia = horario["dia"]
        horario_nuevo.hora_inicio = horario["hora_inicio"]
        horario_nuevo.hora_fin = horario["hora_fin"]
        horario_nuevo.tipo = horario["tipo"]
        horario_nuevo.aula = horario["aula"]

        if horario_nuevo.save
          bitacora "Se guardo el horario del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        else
          errores = '{"error": "Parece que hubo un error y no se pudieron guardar los datos."}'
        end
      end

      success = "ok"
      flash[:exito] = "Se guardó el horario exitosamente."
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de horario del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])
    if __es_del_grupo_docente
      if params[:id] && __es_numero_entero?(params[:id]) && Horario.where(:id => params[:id]).size > 0
        horario = Horario.find(params[:id])
        horario.destroy
        flash[:exito] = "Se eliminó el horario exitosamente."
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "horario", :action => "index"
        return
      end
    end

    flash[:error] = "Disculpe, no se pudo eliminar el horario. Inténtelo nuevamente."
    redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "horario", :action => "index"
    return    
  end
end
