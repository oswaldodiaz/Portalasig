#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def es_ajax?
    unless request.xhr?
      render_404
    end
  end

  def bitacora(descripcion)
    if descripcion
      b = Bitacora.new
      b.descripcion = descripcion
      b.usuario_id = session[:usuario].id if session[:usuario]
      b.fecha = Time.now
      b.ip = request.remote_ip
      b.save
    end
  end

  def bitacora_sitio_web(descripcion,sitio_web_id)
    if descripcion && sitio_web_id
      b = BitacoraSitioWeb.new
      b.descripcion = descripcion
      b.usuario_id = session[:usuario].id
      b.fecha = Time.now
      b.ip = request.remote_ip
      b.sitio_web_id = sitio_web_id
      b.save
    end
  end

  def guardar_en_bitacora(objeto,asignatura,semestre)
    bitacora "Se guardó " + objeto + " del sitio web de la asignatura " + asignatura + " para el período " + semestre
  end

  #Métodos de validación
  def __es_numero_entero?(numero)
    return ( (numero =~ /^\d+$/)? true : false)
  end

  def __es_numero_flotante?(numero)
    return ( (numero =~ /^\d+([,.]\d+)?$/)? true : false)
  end

  def __es_palabra_alfabetica?(palabra)
    return ( (palabra =~ /^[a-zA-ZáéíóúÁÉÍÓÚÑñ]+$/)? true : false)
  end

  def __son_palabras_alfabeticas?(palabras)
    return false if palabras == nil
    return ( ( __es_palabra_alfabetica?(palabras.gsub(/\s+/, "") ) )? true : false)
  end

  def __es_palabra_alfanumerica?(palabra)
    return ( (palabra =~ /^[0-9a-zA-ZáéíóúÁÉÍÓÚÑñ]+$/)? true : false)
  end

  def __son_palabras_alfanumericas?(palabras)
    return false if palabras == nil
    return ( ( __es_palabra_alfanumerica?(palabras.gsub(/\s+/, "") ) )? true : false)
  end

  def __es_correo?(correo)
    return ( (correo =~ /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/)? true : false)
  end

  def __es_token?(token)
    return ( (token =~ /^[a-zA-Z0-9_-]+$/)? true : false)
  end

  def __es_codigo_de_asignatura?(numero)
    return false if numero == nil
    return false if ( !__es_numero_entero?(numero))
    return false if numero.length != 4
    return true
  end

  def __es_semestre?(palabra)
    return false if palabra == nil
    return ((palabra.downcase =~ /semestre(.*)/)? true : false)
  end

  def __es_semestre_valido?(semestre)
    return false if semestre == nil
    array_semestre = semestre.downcase.split(" ")
    if array_semestre.length == 2
      if array_semestre[0] =~ /^semestre$/
        case array_semestre[1]
        when "i"
          return true
        when "ii"
          return true
        when "iii"
          return true
        when "iv"
          return true
        when "v"
          return true
        when "vi"
          return true
        when "vii"
          return true
        when "viii"
          return true
        when "ix"
          return true
        when "x"
          return true
        end
      end
    end

    return false
  end

  def __semestre_correspondiente(semestre)
    return nil if semestre == nil
    array_semestre = semestre.downcase.split(" ")
    if array_semestre.length == 2
      if array_semestre[0] =~ /^semestre$/
        case array_semestre[1]
        when "i"
          return "Semestre I"
        when "ii"
          return "Semestre II"
        when "iii"
          return "Semestre III"
        when "iv"
          return "Semestre IV"
        when "v"
          return "Semestre V"
        when "vi"
          return "Semestre VI"
        when "vii"
          return "Semestre VII"
        when "viii"
          return "Semestre VIII"
        when "ix"
          return "Semestre IX"
        when "x"
          return "Semestre X"
        end
      end
    end

    return nil
  end

  def __es_mencion?(mencion)
    return false if mencion == nil
    mencion.split(" ").each do |palabra|
      return false if !(palabra =~ /^[\(\)a-zA-Z0-9,._-áéíóúÁÉÍÓÚÑñ]+$/)
    end
    return true
  end

  def __es_semestre_o_mencion?(clasificacion)
    return false if clasificacion == nil
    return true if __es_semestre_valido?(clasificacion)
    return true if !__es_semestre?(clasificacion) and __es_mencion?(clasificacion)
    return false
  end

  def __es_nombre_url?(mencion)
    return false if mencion == nil
    return true if mencion.split(" ").size == 1
  end

  def __es_string_valido?(string)
    return false if string == nil || string == ""
    return false if !(string.gsub(/\s+/, "") =~ /^[\=\!\¡\'\"\@\$\&\/\(\)\-\_\.\%\,\°\#\¿\?\¡\!\[\]\:\;\+\<\>a-zA-Z0-9áéíóúÁÉÍÓÚÑñ]+$/)
    return true
  end

  def __es_periodo_valido?(semestre)
    return false if semestre == nil
    if semestre
      if semestre.split("-").length == 2
        periodo = semestre.split("-")[0]
        ano_lectivo = semestre.split("-")[1]

        if periodo == "1" or periodo == "I" or periodo == "2"
          if __es_numero_entero?(ano_lectivo)
            return true
          end
        end
      end
    end
    return false
  end

  def __fecha_valida?(fecha)
    return false if fecha == nil
    arreglo_fecha = fecha.split("/")
    if arreglo_fecha.length == 3
      if __es_numero_entero?(arreglo_fecha[0]) && __es_numero_entero?(arreglo_fecha[1]) && __es_numero_entero?(arreglo_fecha[2])
        hoy = Date.today;
        if Date.new(arreglo_fecha[2].to_i, arreglo_fecha[1].to_i, arreglo_fecha[0].to_i)
          return true
        end
      end
    end
    return false
  end

  def verificar_administrador_autenticado
    unless session[:usuario] && session[:usuario].es_administrador?
      bitacora "Intento de acceso sin autenticacion"
      redirect_to :action => "index", :controller => "inicio"
      return false
    end
  end
  
  def verificar_sitio_web
    unless params[:asignatura_nombre] && params[:semestre]
      flash[:error] = "Sitio web no especificado."
      redirect_to :action => "index", :controller => "inicio"
      return
    end
    
    unless __es_nombre_url?(params[:asignatura_nombre]) && __es_periodo_valido?(params[:semestre])
      flash[:error] = "Disculpe, parece que este sitio ya no existe."
      redirect_to :action => "index", :controller => "inicio"
      return
    end

    unless SitioWeb.sitio_valido(params[:asignatura_nombre],params[:semestre])
      flash[:error] = "Disculpe, parece que este sitio ya no existe."
      redirect_to :action => "index", :controller => "inicio"
      return
    end
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
    if params[:mensaje]
      flash[:exito] = params[:mensaje]
    else
      flash[:exito] = nil
    end
  end

  def __es_del_grupo_docente
    if session[:usuario] && params[:asignatura_nombre] && params[:semestre]
      sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      if Preparador.where(:estudiante_id => session[:usuario].id, :sitio_web_id => sitio_web.id).size > 0 ||
        DocenteSitioWeb.where(:docente_id => session[:usuario].id, :sitio_web_id => sitio_web.id).size > 0
        return true
      end
    end
    return nil
  end

  def __es_docente_del_grupo_docente?
    if session[:usuario]
      sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
      if DocenteSitioWeb.where(:docente_id => session[:usuario].id, :sitio_web_id => sitio_web.id).size > 0
        return true
      end
    end
    return nil
  end

  def verificar_que_pertenece_al_sitio_web
    unless params[:asignatura_nombre] && params[:semestre]
      flash[:error] = "Sitio web no especificado."
      redirect_to :action => "index", :controller => "inicio"
      return
    end
    
    unless __es_nombre_url?(params[:asignatura_nombre]) && __es_periodo_valido?(params[:semestre])
      flash[:error] = "Disculpe los parametros no son validos. Intentelo nuevamente."
      redirect_to :action => "index", :controller => "inicio"
      return
    end

    unless SitioWeb.sitio_valido(params[:asignatura_nombre],params[:semestre])
      flash[:error] = "Disculpe, el sitio web no existe en el sistema. Intentelo nuevamente."
      redirect_to :action => "index", :controller => "inicio"
      return
    end

    sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre], params[:semestre])

    unless session[:usuario] && session[:usuario].id && __es_numero_entero?(session[:usuario].id.to_s)
      flash[:error] = "Disculpe, debe iniciar sesión en el sistema para ver esta opción."
      redirect_to :action => "index", :controller => "informacion_general", :asignatura_nombre => params[:asignatura_nombre], :semestre => params[:semestre]
      return
    end

    unless sitio_web.pertenece_al_sitio_web?(session[:usuario].id)
      flash[:error] = "Disculpe, usted no tiene autorización para acceder a este sitio."
      redirect_to :action => "index", :controller => "informacion_general", :asignatura_nombre => params[:asignatura_nombre], :semestre => params[:semestre]
      return
    end
  end
  
end
