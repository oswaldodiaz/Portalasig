# -*- encoding : utf-8 -*-
class CalificacionController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_que_pertenece_al_sitio_web"
  before_filter :es_ajax?, :only => [:editar]

  def index
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    
    unless session[:usuario] && @sitio_web.pertenece_al_sitio_web?(session[:usuario].id)
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end

    @seccion = "calificaciones"
    if session[:usuario]
      @pertenece_al_sitio_web = @sitio_web.pertenece_al_sitio_web?(session[:usuario].id)
    else
      @pertenece_al_sitio_web = false
    end
  end

  def editar
    errores = ""
    success = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente      
      if params[:calificaciones] && params[:evaluacion_id]
        evaluacion_id = params[:evaluacion_id]

        if __es_numero_entero?(evaluacion_id) && Evaluacion.where(:id => evaluacion_id).size > 0
          calificaciones = params[:calificaciones]

          calificaciones.each_with_index do |dato, i|
            calificacion = JSON.parse(dato, nil);
            
            if calificacion["estudiante_id"] == nil || calificacion["estudiante_id"] == ""
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El id del estudiante de la calificacion '+(i+1).to_s+' no puede estar vacío."}'
            elsif !__es_numero_entero?(calificacion["estudiante_id"])
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El id del estudiante de la calificacion '+(i+1).to_s+' debe ser numérico."}'
            elsif !sitio_web.es_estudiante_del_sitio_web?(calificacion["estudiante_id"])
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El id del estudiante de la calificacion '+(i+1).to_s+' no pertenece al sitio web."}'
            else
              if calificacion["nota"] != nil && calificacion["nota"] != ""
                if !__es_numero_flotante?(calificacion["nota"])
                  errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La calificacion del estudiante '+Usuario.where(:id => calificacion["estudiante_id"]).first.nombre_y_apellido+' debe ser un número entero o real."}'
                end
              end
            end
          end
        else
          errores = '{"error": "Disculpe, parace que esta evaluación ya no existe en el sistema."}'
        end
      else
        errores = '{"error": "No se pudo guardar ninguna nota."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      calificaciones.each_with_index do |dato, i|
        calificacion = JSON.parse(dato, nil);
        unless nota = Calificacion.where(:evaluacion_id => evaluacion_id, :estudiante_id => calificacion["estudiante_id"]).first
          nota = Calificacion.new
          nota.evaluacion_id = evaluacion_id
          nota.estudiante_id = calificacion["estudiante_id"]          
        end

        nota_vieja = nota.calificacion

        if calificacion["nota"] != nil && calificacion["nota"] != ""
          nota.calificacion = calificacion["nota"].gsub(",",".").to_f
        else
          nota.calificacion = nil
        end

        if nota.save
          bitacora "Se guardo la nota #{nota.id} del estudiante #{nota.estudiante.usuario.nombre_y_apellido} en la evaluacion #{nota.evaluacion.nombre} del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
          if nota.calificacion != nil && nota_vieja != nota.calificacion
            if nota_vieja != nil
              bitacora_sitio_web "Modificó la nota del estudiante #{nota.estudiante.usuario.nombre_y_apellido} de #{nota_vieja} a #{nota.calificacion} en la evaluación #{nota.evaluacion.nombre}", sitio_web.id
            end
            Mailer.notificar_nota_a_estudiante(nota.estudiante.usuario, session[:usuario], nota.evaluacion, sitio_web)
          end
        else
          errores = '{"error": "Parece que hubo un error y no se pudieron guardar los datos."}'
        end

      end

      success = "ok"
      flash[:exito] = "Se guardaron las calificaciones exitosamente."
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
      Mailer.notificar_nota_a_grupo_docente(sitio_web.correos_grupo_docente, session[:usuario],  Evaluacion.where(:id => params[:evaluacion_id]).first, sitio_web)
    else
      bitacora "Intento fallido de edición de calificaciones del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end


  #Este metodo cargara las calfiicaciones para su posterior descarga
  def descargar_calificaciones
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    if __es_del_grupo_docente

      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new

      bold = Spreadsheet::Format.new :weight => :bold
      
      sheets = []
   
      hoja = 0
      fila = 0
      col = 0

      tipos = ["Teoría","Práctica","Laboratorio","Otro"]

      sitio_web.seccion_sitio_web.each_with_index do |seccion_sitio_web, index|
        sheet = book.create_worksheet :name => seccion_sitio_web.seccion.nombre.to_s
        fila = 0
        col = 0
        sheet[fila,col] = "Sección: "+seccion_sitio_web.seccion.nombre

        sheet.row(fila).set_format(col, bold)

        fila = 1
        sheet[fila,col] = "Cédula"
        sheet.row(fila).set_format(col, bold)
        col = 1

        sheet[fila,col] = "Estudiante"
        sheet.row(fila).set_format(col, bold)
        col = 2
        


        tipos.each do |tipo|
          if Evaluacion.where(:sitio_web_id => sitio_web.id, :tipo => tipo).size > 0
            Evaluacion.where(:sitio_web_id => sitio_web.id, :tipo => tipo).each do |evaluacion|
              sheet[fila,col] = evaluacion.nombre
              sheet.row(fila).set_format(col, bold)
              col += 1
            end
            sheet[fila,col] = "Total " + tipo
            sheet.row(fila).set_format(col, bold)
            col += 1
          end
        end

        sheet[fila,col] = "Total"
        sheet.row(fila).set_format(col, bold)

        

        fila += 1
        col = 0

        Usuario.order(:apellido, :nombre).where(:id => EstudianteSeccionSitioWeb.where(
          :seccion_sitio_web_id => seccion_sitio_web.id).collect{|x| x.estudiante_id}).each do |usuario|
          col = 0
          sheet[fila,col] = usuario.cedula
          col = 1
          sheet[fila,col] = (usuario.apellido + " " + usuario.nombre)
          col = 2

          total = 0
          suma = 0

          porcentaje = Evaluacion.where(:sitio_web_id => sitio_web.id).sum("valor")

          tipos.each_with_index do |tipo|
            if Evaluacion.where(:sitio_web_id => sitio_web.id, :tipo => tipo).size > 0
              suma = 0
              Evaluacion.where(:sitio_web_id => sitio_web.id, :tipo => tipo).each do |evaluacion|
                if calificacion = Calificacion.where(:evaluacion_id => evaluacion.id, :estudiante_id => usuario.id).first
                  if calificacion.calificacion
                    sheet[fila,col] = calificacion.calificacion
                    suma += (evaluacion.valor.to_f*calificacion.calificacion.to_f)
                  end
                end
                col += 1
              end
              sheet[fila,col] = (suma/porcentaje).round(2)
              total += suma
              col += 1
            end
          end

          sheet[fila,col] = (total/porcentaje).round(2)
          sheet.row(fila).set_format(col, bold)
          fila += 1
        end

        sheets[hoja] = sheet
      end



      ruta = ("#{Rails.root}/doc/calificaciones/calificaciones.xls").to_s

      book.write ruta

      send_file ruta, :filename => "Calificaciones de "+sitio_web.asignatura.nombre + " " + sitio_web.periodo + ".xls"

      return
    end

    flash[:error] = "Parece que no se puede realizar la descarga en este momento. Inténtelo nuevamente."
    redirect_to :back
  end
end
