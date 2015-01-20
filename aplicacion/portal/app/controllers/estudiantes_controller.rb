# -*- encoding : utf-8 -*-
class EstudiantesController < ApplicationController

  layout "sitio_web"

  before_filter "verificar_sitio_web"
  before_filter :es_ajax?, :only => [:procesar_agregar_estudiante_a_seccion]

  def index
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    
    unless __es_del_grupo_docente
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end

    @seccion = "estudiantes"    
    @secciones_sitio_web = SeccionSitioWeb.where(:sitio_web_id => @sitio_web.id)
  end

  #Vista donde se visualiza el formulario para crear un estudiante
  def agregar_estudiante_a_seccion
    
    if __es_del_grupo_docente && params[:id] && __es_numero_entero?(params[:id]) && SeccionSitioWeb.where(:id => params[:id]).size > 0
      @seccion = "estudiantes"
      @seccion_sitio_web = SeccionSitioWeb.where(:id => params[:id]).first
      @cedulas = Usuario.order("cedula").where(:id => Estudiante.all).collect{ |x| x.cedula.to_s}.uniq
      return
    end

    redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
    return
  end

  #Método que guarda el estudiante en el sistema
  def procesar_agregar_estudiante_a_seccion
    errores = ""
    success = ""
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    if __es_del_grupo_docente && params[:seccion_sitio_web_id] && params[:cedula] && 
      params[:nombre] && params[:apellido] && params[:correo]
          
      #Se guardan los parametros en variables locales para mejor manejo del sistema
      cedula = params[:cedula]
      nombre = params[:nombre]
      apellido = params[:apellido]
      correo = params[:correo]
      seccion_sitio_web_id = params[:seccion_sitio_web_id]


      #Se validan los campos, cada una de estas validaciones son globales para los controladores,
      # por lo que se encuentran en application_controller.rb
      unless seccion_sitio_web_id && __es_numero_entero?(seccion_sitio_web_id) && SeccionSitioWeb.where(:id => seccion_sitio_web_id).size > 0
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Esta sección ya no existe."}'
      end

      if cedula == nil || cedula == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar la cédula"}'
      elsif !__es_numero_entero?(cedula)
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"La cédula debe ser numérica."}'
      end

      if nombre == nil || nombre == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el nombre"}'
      end

      if apellido == nil || apellido == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el apellido"}'
      end

      if correo == nil || correo == ""
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"Debe insertar el correo"}'
      elsif !__es_correo?(correo)
        errores += ( (errores.length == 0)? "{" : ", {") + '"error":"El correo no tiene el formato adecuado."}'
      end

      unless errores.length > 0
        #Si los datos son correctos, se verifica que exista un usuario valido
        ya_estaba = false
        if usuario = Usuario.where(:cedula => cedula).first
          ya_estaba = true
          if Usuario.where("id != ? AND correo = ?", usuario.id, correo).size > 0
            errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
          end
        else
          if Usuario.where(:correo => correo).size > 0
            errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Ya existe un usuario en el sistema con este correo."}'
          else
            usuario = Usuario.new
            usuario.cedula = cedula
          end
        end
      end

      unless errores.length > 0
        usuario.nombre = nombre
        usuario.apellido = apellido
        usuario.correo = correo

        if usuario.save
          Mailer.registro_de_usuario(usuario) unless ya_estaba
          bitacora "Se ha guardado al usuario #{usuario.nombre_y_apellido}"

          #Una vez guardado el usuario se crea el estudiante que hereda el id de usuario y se guarda
          unless estudiante = Estudiante.where(:id => usuario.id).first
            estudiante = Estudiante.new
            estudiante.id = usuario.id
            estudiante.save
            bitacora "Se ha guardado al estudiante #{estudiante.usuario.nombre_y_apellido}"
          end

          unless estudiante_seccion = EstudianteSeccionSitioWeb.where(:estudiante_id => estudiante.id, :seccion_sitio_web_id => seccion_sitio_web_id).first
            estudiante_seccion = EstudianteSeccionSitioWeb.new
            estudiante_seccion.estudiante_id = estudiante.id
            estudiante_seccion.seccion_sitio_web_id = seccion_sitio_web_id
            estudiante_seccion.save
            bitacora "Se ha guardado al estudiante #{estudiante.usuario.nombre_y_apellido} en la asignatura #{params[:asignatura_nombre]} para el período #{params[:semestre]}"
          end

          #Se muestra el mensaje de exito
          success = "ok"
          Mailer.notificar_se_agrego_a_sitio_Web(usuario,@sitio_web)
          flash[:exito] = "Se ha agregado al estudiante exitosamente."
        end
      end

    else
      errores = ( (errores.length == 0)? "{" : ", {") + '"error":"Usted no tiene autorización para realizar esta acción. #{__es_del_grupo_docente} #{params[:seccion_sitio_web_id]} #{params[:cedula]} #{params[:nombre]} #{params[:apellido]} #{params[:correo]} " }'
    end
  
    if success == "ok"
      render :json => JSON.parse('{"success":"ok"}')
    else
      bitacora "Intento fallido de agregacion de estudiante a estudiante seccion con los datos #{params[:seccion_sitio_web_id]} #{params[:cedula]} #{params[:nombre]} #{params[:apellido]} #{params[:correo]} "
      render :json => JSON.parse('{"success":"error", "errores":['+errores+'] }')
    end
  end


  #Eliminar estudiantes seleccionados en la vista estudiantes
  def eliminar_estudiante_seccion_sitio_web
    if __es_del_grupo_docente
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      #Primero se verifica que se enviaron datos a través de un formulario
      #Para esto basta con probar que la variable params[:estudiantes] existe
      unless params[:id] && __es_numero_entero?(params[:id]) && SeccionSitioWeb.where(:id => params[:id]).size > 0
        flash[:error] = "Disculpe, no se pudo eliminar a los estudiantes seleccionados"
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
        return
      end
      seccion_sitio_web = SeccionSitioWeb.find(params[:id])

      unless params[:seccion_sitio_web] && params[:seccion_sitio_web]["cantidad_#{seccion_sitio_web.id}"]
        flash[:error] = "Disculpe, no se especificó un estudiante. Inténtelo nuevamente."
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
        return
      end

      #Esta variable almacenara cuantos estudiantes (checkboxs) existian en el formulario
      cant = params[:seccion_sitio_web]["cantidad_#{seccion_sitio_web.id}"].to_i

      #se itera sobre cada posible estudiante eliminando el que haya sido seleccionado
      for i in 1..cant do
        #En rails solo los checkbox seleccionados son enviados por parametro al servidor, por lo que
        #si el parametro existe, entonces fue seleccionado y por ende debe ser eliminado
        if id = params["check_box_estudiante_seccion_#{seccion_sitio_web.id}_"+i.to_s]
          estudiante_seccion_sitio_web = EstudianteSeccionSitioWeb.where(:estudiante_id => id, 
                                          :seccion_sitio_web_id => seccion_sitio_web.id).first
          estudiante_seccion_sitio_web.destroy
        end
      end

      flash[:exito] = "Se eliminaron los estudiantes seleccionados exitosamente."      
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
      return
    end
    redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
    return
  end

  def eliminar_seccion
    if __es_del_grupo_docente
      @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      #Primero se verifica que se enviaron datos a través de un formulario
      #Para esto basta con probar que la variable params[:estudiantes] existe
      unless params[:id] && __es_numero_entero?(params[:id]) && SeccionSitioWeb.where(:id => params[:id]).size > 0
        redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
        return
      end
      seccion_sitio_web = SeccionSitioWeb.where(:id => params[:id]).first
      Seccion.destroy_seccion_sitio_web(seccion_sitio_web.seccion.id,@sitio_web.id)

      flash[:exito] = "Se elimino la seccion exitosamente."      
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
      return
    else
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "estudiantes", :action => "index"
      return
    end
  end

end
