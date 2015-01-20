# -*- encoding : utf-8 -*-
class HistoricoController < ApplicationController
  
  layout "sitio_web"

  before_filter "verificar_sitio_web"

  def index
    @seccion = "historico"
    @es_del_grupo_docente = __es_del_grupo_docente
    @sitio_web = SitioWeb.sitio_actual(params[:asignatura_nombre],params[:semestre])
  end
end
