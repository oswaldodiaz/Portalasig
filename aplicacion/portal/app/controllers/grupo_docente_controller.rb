# -*- encoding : utf-8 -*-
class GrupoDocenteController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_editar_docentes, :procesar_editar_preparadores]

  def index
    @seccion = "grupo_docente"
    @es_del_grupo_docente = __es_del_grupo_docente
    @es_docente = __es_docente_del_grupo_docente?
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    @docentes = DocenteSitioWeb.order("docente_id").where(:sitio_web_id => @sitio_web.id)
    @preparadores = Preparador.where(:sitio_web_id => @sitio_web.id)
  end

  def editar_docentes
    @seccion = "grupo_docente"
    @es_del_grupo_docente = __es_del_grupo_docente
    if @es_del_grupo_docente
      @es_docente = __es_docente_del_grupo_docente?
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      @secciones = Seccion.order("nombre").all.collect{ |x| x.nombre}.uniq
      @tipos = ["Coordinador","Docente", "Otro"]
      @cedulas = Usuario.where(:id => Docente.all).collect{ |x| x.cedula.to_s}.uniq
      return
    else
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "grupo_docente", :action => "index"
      return
    end
  end

  def procesar_editar_docentes
    errores = ""
    success = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente      
      if params[:docentes]
        docentes = params[:docentes]
        docentes.each_with_index do |dato, i|
          docente = JSON.parse(dato, nil);
          
          if docente["cedula"] == nil || docente["cedula"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la cédula del docente '+(i+1).to_s+'"}'
          elsif !(Docente.where(:id => Usuario.select("id").where(:cedula => docente["cedula"].to_i)).size > 0)
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula '+(i+1).to_s+' no pertenece a ningún docente."}'
          end

          if docente["correo"] == nil || docente["correo"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el correo del docente '+(i+1).to_s+'"}'
          end

          if docente["seccion"] == nil || docente["seccion"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la sección del docente '+(i+1).to_s+'"}'
          end

        end
      else
        errores = '{"error": "No se pudo guardar ningún docente."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      docentes.each do |dato|
        docente = JSON.parse(dato, nil);
        docente_id = Docente.where(:id => Usuario.where(:cedula => docente["cedula"].to_i)).first.id.to_i

        unless seccion = Seccion.where(:nombre => docente["seccion"]).first
          seccion = Seccion.new
          seccion.asignatura_id = sitio_web.asignatura.id
          seccion.semestre_id = sitio_web.semestre.id
        end

        seccion.nombre = docente["seccion"].upcase
        seccion.save
        bitacora "Se guardó la seción #{seccion.nombre}"

        unless docente_sitio_web = DocenteSitioWeb.where(:sitio_web_id => sitio_web.id, :docente_id => docente_id, :seccion_id => nil).first
          unless docente_sitio_web = DocenteSitioWeb.where(:sitio_web_id => sitio_web.id, :docente_id => docente_id, :seccion_id => seccion.id).first
            docente_sitio_web = DocenteSitioWeb.new
            docente_sitio_web.docente_id = docente_id
            docente_sitio_web.sitio_web_id = sitio_web.id
          end
        end

        docente_sitio_web.seccion_id = seccion.id
        docente_sitio_web.correo = docente["correo"]
        docente_sitio_web.tipo = docente["tipo"]
        
        esta = false
        if sitio_web.docente_sitio_web.size > 0
          sitio_web.docente_sitio_web.each do |docente_sitio_web_a|
            if docente_sitio_web_a.docente.usuario.cedula == docente["cedula"].to_i && docente_sitio_web_a.seccion_nombre.downcase == docente["seccion"].downcase
              esta = true 
              break
            end
          end
        end

        if docente_sitio_web.save
          bitacora "Se guardaron los docentes del grupo docente del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
          success = "ok"
          Mailer.notificar_se_agrego_a_sitio_Web(docente_sitio_web.docente.usuario, sitio_web) unless esta
          flash[:exito] = "Se guardaron los docentes del grupo docente satisfactoriamente."
        else
          errores = '{"error": "Parece que hubo un error y no se pudieron guardar los datos."}'
        end
      end

      if sitio_web.docente_sitio_web.size > 0
        sitio_web.docente_sitio_web.each do |docente_sitio_web|
          esta = false
          docentes.each do |dato|
            docente = JSON.parse(dato, nil);
            if docente_sitio_web.docente.usuario.cedula == docente["cedula"].to_i && docente_sitio_web.seccion_nombre.downcase == docente["seccion"].downcase
              esta = true 
              break
            end
          end

          unless esta
            seccion_id = docente_sitio_web.seccion_id if docente_sitio_web.seccion
            if docente_sitio_web.docente.id != sitio_web.usuario_id
              docente_sitio_web.destroy
            elsif DocenteSitioWeb.where(:docente_id => docente_sitio_web.docente.id, :sitio_web_id => sitio_web.id).size > 1
              texto = "Se eliminó la sección #{docente_sitio_web.seccion.nombre} del docente #{docente_sitio_web.docente.usuario.nombre_y_apellido} de la asignatura #{params[:asignatura_nombre]} para el semestre #{params[:semestre]}" if docente_sitio_web.seccion
              docente_sitio_web.destroy
              bitacora texto if docente_sitio_web.seccion
            end

            if seccion_id
              if DocenteSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0 && 
                Preparador.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0
                if seccion_sitio_web = SeccionSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).first

                  seccion_sitio_web.destroy
                  bitacora "Se eliminó la sección #{seccion_id} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"

                  if SeccionSitioWeb.where(:seccion_id => seccion_id).size == 0 
                    if seccion = Seccion.find(seccion_id)
                      seccion.destroy
                      bitacora "Se eliminó la sección #{seccion_id}"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de docentes al grupo docente del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar_docente
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente
      if params[:id] && __es_numero_entero?(params[:id]) && DocenteSitioWeb.where(:id => params[:id]).size > 0
        docente_sitio_web = DocenteSitioWeb.where(:id => params[:id]).first            
        if docente_sitio_web.docente.id != sitio_web.usuario_id || (docente_sitio_web.docente.id == sitio_web.usuario_id && 
          DocenteSitioWeb.where(:docente_id => docente_sitio_web.docente.id, :sitio_web_id => sitio_web.id).size > 1)
          
          seccion_id = docente_sitio_web.seccion_id if docente_sitio_web.seccion

          texto = "Se eliminó al docente #{docente_sitio_web.docente.usuario.nombre_y_apellido} del grupo docente de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
          docente_sitio_web.destroy

          flash[:exito] = "Se eliminó al docente exitosamente."
          bitacora texto

          if seccion_id
            if DocenteSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0 && 
              Preparador.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0
              if seccion_sitio_web = SeccionSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).first
                seccion_sitio_web.destroy
                bitacora "Se eliminó la sección #{seccion_id} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"

                if SeccionSitioWeb.where(:seccion_id => seccion_id).size == 0 
                  if seccion = Seccion.find(seccion_id)
                    seccion.destroy
                    bitacora "Se eliminó la sección #{seccion_id}"
                  end
                end
              end
            end
          end
          redirect_to :asignatura_nombre => sitio_web.nombre_url, :semestre => sitio_web.periodo, :controller => "grupo_docente", :action => "index"
          return
        else
          flash[:error] = "Disculpe, no se puede borrar al docente creador del sitio web. Inténtelo nuevamente."
          bitacora "Intento fallido al borrar al docente creador del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
          redirect_to :back
          return
        end
      end
      flash[:error] = "Disculpe, parece que no se pudo borrar al docente. Inténtelo nuevamente."
      bitacora "Intento fallido al borrar al docente con id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      redirect_to :back
      return
    end
    unless flash[:error]
      bitacora "Intento fallido al borrar al docente del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]} por falta de autorización"
    end
    redirect_to :asignatura_nombre => sitio_web.nombre_url, :semestre => sitio_web.periodo, :controller => "grupo_docente", :action => "index"
  end



  def editar_preparadores
    @seccion = "grupo_docente"
    @es_del_grupo_docente = __es_del_grupo_docente
    if @es_del_grupo_docente
      @es_docente = __es_docente_del_grupo_docente?
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      @secciones = Seccion.order("nombre").all.collect{ |x| x.nombre}.uniq
      @tipos = ["Auxiliar docente","Preparador I", "Preparador II", "Otro"]
      @cedulas = Usuario.where(:id => Estudiante.all).collect{ |x| x.cedula.to_s}.uniq
      return
    else
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "grupo_docente", :action => "index"
      return
    end
  end

  def procesar_editar_preparadores
    errores = ""
    success = ""
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente      
      if params[:preparadores]
        preparadores = params[:preparadores]
        preparadores.each_with_index do |dato, i|
          preparador = JSON.parse(dato, nil);
          
          if preparador["cedula"] == nil || preparador["cedula"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula del preparador '+(i+1).to_s+' no puede estar vacía."}'
          elsif !__es_numero_entero?(preparador["cedula"])
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula del preparador '+(i+1).to_s+' debe ser numérica."}'
          elsif usuario = Usuario.where(:cedula => preparador["cedula"]).first
            if Docente.where(:id => usuario.id).first
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula '+(i+1).to_s+' no puede pertenecer a un docente."}'
            end
          end

          if preparador["nombre"] == nil || preparador["nombre"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre del preparador '+(i+1).to_s+'"}'
          end

          if preparador["apellido"] == nil || preparador["apellido"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el apellido del preparador '+(i+1).to_s+'"}'
          end

          if preparador["correo"] == nil || preparador["correo"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el correo del preparador '+(i+1).to_s+'"}'
          elsif !__es_correo?(preparador["correo"])
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El correo del preparador '+(i+1).to_s+' no tiene un formato adecuado."}'
          elsif __es_numero_entero?(preparador["cedula"]) && !(Usuario.where(:cedula => preparador["cedula"]).size > 0)
            if Usuario.where(:correo => preparador["correo"]).size > 0
              errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con el correo del preparador '+(i+1).to_s+'."}'
            end
          end

          if preparador["seccion"] == nil || preparador["seccion"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la sección del preparador '+(i+1).to_s+'"}'
          end

          if preparador["tipo"] == nil || preparador["tipo"] == ""
            errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el tipo del preparador '+(i+1).to_s+'"}'
          end

        end
      else
        errores = '{"error": "No se pudo guardar ningún preparador."}'
      end
    else
      errores = '{"error": "Usted no tiene autorización."}'
    end

    unless errores.length > 0
      preparadores.each do |dato|
        preparador = JSON.parse(dato, nil);

        unless usuario = Usuario.where(:cedula => preparador["cedula"]).first
          usuario = Usuario.new
          usuario.cedula = preparador["cedula"]
          usuario.nombre = preparador["nombre"]
          usuario.apellido = preparador["apellido"]
          usuario.correo = preparador["correo"]
          usuario.save
          Mailer.registro_de_usuario(usuario)
          bitacora "Se creó al usuario #{usuario.descripcion}"
        end

        unless estudiante = Estudiante.where(:id => usuario.id).first
          estudiante = Estudiante.new
          estudiante.id = usuario.id
          estudiante.save
          bitacora "Se creó al estudiante #{estudiante.usuario.descripcion}"
        end

        unless seccion = Seccion.where(:nombre => preparador["seccion"]).first
          seccion = Seccion.new
          seccion.asignatura_id = sitio_web.asignatura.id
          seccion.semestre_id = sitio_web.semestre.id
        end

        seccion.nombre = preparador["seccion"].upcase
        seccion.save
        bitacora "Se guardó la seción #{seccion.nombre}"
        
        unless prepa = Preparador.where(:sitio_web_id => sitio_web.id, :estudiante_id => estudiante.id, :seccion_id => seccion.id).first
          prepa = Preparador.new
          prepa.estudiante_id = estudiante.id
          prepa.sitio_web_id = sitio_web.id
        end


        prepa.seccion_id = seccion.id
        prepa.correo = preparador["correo"]
        prepa.tipo = preparador["tipo"]          

        esta = false
        if sitio_web.preparador.size > 0
          sitio_web.preparador.each do |prepa_a|
            if prepa_a.estudiante.usuario.cedula == preparador["cedula"].to_i && prepa_a.seccion_nombre.downcase == preparador["seccion"].downcase
              esta = true 
              break
            end
          end
        end

        if prepa.save
          Mailer.notificar_se_agrego_a_sitio_Web(usuario, sitio_web) unless esta
          bitacora "Se creó al preparador #{prepa.estudiante.usuario.descripcion} para el sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        end
      end

      success = "ok"
      flash[:exito] = "Se guardaron los preparadores del grupo docente satisfactoriamente."
      bitacora "Se guardaron los preparadores del grupo docente del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"

      if sitio_web.preparador.size > 0
        sitio_web.preparador.each do |preparador_sitio_web|
          esta = false
          preparadores.each do |dato|
            preparador = JSON.parse(dato, nil);
            if preparador_sitio_web.estudiante.usuario.cedula == preparador["cedula"].to_i && preparador_sitio_web.seccion_nombre.downcase == preparador["seccion"].downcase
              esta = true 
              break
            end
          end

          unless esta
            seccion_id = preparador_sitio_web.seccion_id if preparador_sitio_web.seccion

            texto = "Se eliminó la sección #{preparador_sitio_web.seccion.nombre} del preparador #{preparador_sitio_web.estudiante.usuario.nombre_y_apellido} de la asignatura #{params[:asignatura_nombre]} para el semestre #{params[:semestre]}" if preparador_sitio_web.seccion
            preparador_sitio_web.destroy
            bitacora texto if preparador_sitio_web.seccion

            if seccion_id
              if DocenteSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0 && 
                Preparador.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0
                if seccion_sitio_web = SeccionSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).first
                  seccion_sitio_web.destroy
                  bitacora "Se eliminó la sección #{seccion_id} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"

                  if SeccionSitioWeb.where(:seccion_id => seccion_id).size == 0
                    if seccion = Seccion.find(seccion_id)
                      seccion.destroy
                      bitacora "Se eliminó la sección #{seccion_id}"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de docentes al grupo docente del sitio_web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end

  def eliminar_preparador
    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if __es_del_grupo_docente
      if params[:id] && __es_numero_entero?(params[:id]) && Preparador.where(:id => params[:id]).size > 0
        preparador = Preparador.where(:id => params[:id]).first
        seccion_id = preparador.seccion_id if preparador.seccion

        texto = "Se eliminó al preparador #{preparador.estudiante.usuario.nombre_y_apellido} del grupo docente de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
        preparador.destroy

        flash[:exito] = "Se eliminó al preparador exitosamente."
        bitacora texto

        if seccion_id
          if DocenteSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0 && 
            Preparador.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).size == 0
            if seccion_sitio_web = SeccionSitioWeb.where(:seccion_id => seccion_id, :sitio_web_id => sitio_web.id).first
              seccion_sitio_web.destroy
              bitacora "Se eliminó la sección #{seccion_id} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"

              if SeccionSitioWeb.where(:seccion_id => seccion_id).size == 0
                if seccion = Seccion.find(seccion_id)
                  seccion.destroy
                  bitacora "Se eliminó la sección #{seccion_id}"
                end
              end
            end
          end
        end

        redirect_to :asignatura_nombre => sitio_web.nombre_url, :semestre => sitio_web.periodo, :controller => "grupo_docente", :action => "index"
        return
      end
      flash[:error] = "Disculpe, parece que no se pudo borrar al preparador. Inténtelo nuevamente."
      bitacora "Intento fallido al borrar al preparador con id #{params[:id]} del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
      redirect_to :back
      return
    end
    unless flash[:error]
      bitacora "Intento fallido al borrar al preparador del sitio web de la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]} por falta de autorización"
    end
    redirect_to :asignatura_nombre => sitio_web.nombre_url, :semestre => sitio_web.periodo, :controller => "grupo_docente", :action => "index"
  end
end
