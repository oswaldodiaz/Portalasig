# -*- encoding : utf-8 -*-
class BitacoraController < ApplicationController
  layout "sitio_web"

  before_filter :verificar_sitio_web

  def index
    unless __es_del_grupo_docente
      redirect_to :asignatura_nombre => @sitio_web.nombre_url, :semestre => @sitio_web.periodo, :controller => "informacion_general", :action => "index"
      return
    end

    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])

    @registros = BitacoraSitioWeb.limit(1000).order("fecha DESC").where(:sitio_web_id => @sitio_web.id)

    @seccion = "registro_de_actividades"
  end
end
