# -*- encoding : utf-8 -*-
class BienvenidaController < ApplicationController
  layout "sitio_web"

  before_filter "verificar_sitio_web"

  def index
    @seccion = "bienvenida"
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    unless __es_del_grupo_docente
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return 
    end
  end
end
