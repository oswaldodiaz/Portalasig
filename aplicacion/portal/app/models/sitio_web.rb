class SitioWeb < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :asignatura
  belongs_to :semestre
  
  has_many :preparador, :dependent => :destroy
  has_many :seccion_sitio_web, :dependent => :destroy
  has_many :docente, :through => :docente_sitio_web
  has_many :estudiante_seccion, :through => :seccion
  has_many :contenido_tematico, :dependent => :destroy
  
  has_many :horario, :dependent => :destroy
  has_many :archivo, :dependent => :destroy
  has_many :evaluacion, :dependent => :destroy
  has_many :calificacion, :through => :evaluacion
  has_many :objetivo, :dependent => :destroy
  has_many :foro, :dependent => :destroy
  has_many :comentario, :through => :foro 
  has_many :evento, :dependent => :destroy
  has_many :docente_sitio_web, :dependent => :destroy

  has_many :bibliography, :dependent => :destroy
  has_many :notice, :dependent => :destroy

  has_many :entrega, :dependent => :destroy

  has_many :bitacora_sitio_web, :dependent => :destroy
  

  after_create :importar_datos

  def agregar_docente_a_grupo_docente
    if usuario = Usuario.where(:id => self.usuario_id).first
      if docente = Docente.find(usuario.id)
        docente_asignatura = DocenteSitioWeb.new
        docente_asignatura.docente_id = docente.id
        docente_asignatura.sitio_web_id = self.id
        docente_asignatura.save
      end
    end
  end

  def nombre_url
    nombre_url = ""
    self.asignatura.nombre.downcase.split(" ").each_with_index do |nombre,index|
      nombre_url << ((index == 0)? "": "_") + nombre
    end

    return nombre_url
  end
  
  def self.nombre_normal(nombre)
    nombre_normal = ""
    nombre.split("_").each_with_index do |nom,index|
      nombre_normal << ((index == 0)? "": " ") + nom
    end

    return ( (Asignatura.where(:nombre => nombre_normal).size > 0)? Asignatura.where(:nombre => nombre_normal).first.nombre : "")
  end

  def periodo
    return self.semestre.periodo_academico + "-" + self.semestre.ano_lectivo.to_s
  end

  def self.sitio_valido(asignatura_nombre,semestre)
    if asignatura = Asignatura.where(:nombre => SitioWeb.nombre_normal(asignatura_nombre)).first
      if semestre = Semestre.where(:periodo_academico => semestre.split("-")[0], :ano_lectivo => semestre.split("-")[1]).first
        if SitioWeb.where(:asignatura_id => asignatura.id, :semestre_id => semestre.id).size > 0
          return true
        end
      end
    end
    return false
  end

  def self.sitio_actual(asignatura_nombre,semestre)
    @sitio_web = SitioWeb.where(:asignatura_id => 
      Asignatura.where(:nombre => 
        SitioWeb.nombre_normal(asignatura_nombre)).first.id,
        :semestre_id => Semestre.where(:periodo_academico => semestre.split("-")[0],
          :ano_lectivo => semestre.split("-")[1]).first.id
        ).first
  end

  def creador
    usuario = Usuario.where(:id => self.usuario_id).first
  end

  def docentes
    DocenteSitioWeb.order("docente_id").where(:sitio_web_id => self.id)
  end

  def preparadores
    Preparador.where(:sitio_web_id => self.id)
  end

  def estudiantes
    Usuario.where(:id => EstudianteSeccionSitioWeb.where(:seccion_sitio_web_id => 
                        SeccionSitioWeb.where(:sitio_web_id => self.id).collect{|x| x.id}
                  ).collect{|x| x.estudiante_id})
  end

  def pertenece_al_sitio_web?(id)
    if DocenteSitioWeb.where(:docente_id => id, :sitio_web_id => self.id).size > 0 || 
      Preparador.where(:estudiante_id => id, :sitio_web_id => self.id).size > 0 || 
      EstudianteSeccionSitioWeb.where(:estudiante_id => id, :seccion_sitio_web_id => SeccionSitioWeb.where(:sitio_web_id => self.id).collect{|x| x.id}.uniq).size > 0
      return true
    end
    return false
  end

  def es_estudiante_del_sitio_web?(id)
    if EstudianteSeccionSitioWeb.where(:estudiante_id => id, :seccion_sitio_web_id => SeccionSitioWeb.where(:sitio_web_id => self.id).collect{|x| x.id}.uniq).size > 0
      return true
    end
    return false
  end

  def tiene_evaluaciones_con_fecha
    return Evaluacion.where('sitio_web_id = ? AND fecha_inicio != ?', self.id, "null").size > 0
  end

  def total_evaluaciones
    return Evaluacion.where(:sitio_web_id => self.id).sum("valor")    
  end

  def importar_datos
    if SitioWeb.where(:asignatura_id => self.asignatura.id).size > 1
      ultimo_sitio = SitioWeb.order("created_at desc").where(:asignatura_id => self.asignatura.id)[1]

      if ultimo_sitio.objetivo.size > 0
        ultimo_sitio.objetivo.each do |objeto_viejo|
          objeto_nuevo = Objetivo.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.descripcion = objeto_viejo.descripcion
          objeto_nuevo.save
        end
      end

      if ultimo_sitio.bibliography.size > 0
        ultimo_sitio.bibliography.each do |objeto_viejo|
          objeto_nuevo = Bibliography.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.titulo = objeto_viejo.titulo
          objeto_nuevo.descripcion = objeto_viejo.descripcion
          objeto_nuevo.autores = objeto_viejo.autores
          objeto_nuevo.save
        end
      end

      if ultimo_sitio.contenido_tematico.size > 0
        ultimo_sitio.contenido_tematico.each do |objeto_viejo|
          objeto_nuevo = ContenidoTematico.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.titulo = objeto_viejo.titulo
          objeto_nuevo.descripcion = objeto_viejo.descripcion
          objeto_nuevo.save
        end
      end

      if ultimo_sitio.evaluacion.size > 0
        ultimo_sitio.evaluacion.each do |objeto_viejo|
          objeto_nuevo = Evaluacion.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.tipo = objeto_viejo.tipo
          objeto_nuevo.nombre = objeto_viejo.nombre
          objeto_nuevo.valor = objeto_viejo.valor
          objeto_nuevo.save
        end
      end

      if ultimo_sitio.seccion_sitio_web.size > 0
        ultimo_sitio.seccion_sitio_web.each do |objeto_viejo|
          objeto_nuevo = SeccionSitioWeb.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.seccion_id = objeto_viejo.seccion_id
          objeto_nuevo.save
        end
      end

      if ultimo_sitio.docente_sitio_web.size > 0
        ultimo_sitio.docente_sitio_web.each do |objeto_viejo|
          objeto_nuevo = DocenteSitioWeb.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.docente_id = objeto_viejo.docente_id
          objeto_nuevo.seccion_id = objeto_viejo.seccion_id
          objeto_nuevo.tipo = objeto_viejo.tipo
          objeto_nuevo.correo = objeto_viejo.correo
          objeto_nuevo.save
        end
      end

      if ultimo_sitio.preparador.size > 0
        ultimo_sitio.preparador.each do |objeto_viejo|
          objeto_nuevo = Preparador.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.estudiante_id = objeto_viejo.estudiante_id
          objeto_nuevo.seccion_id = objeto_viejo.seccion_id
          objeto_nuevo.tipo = objeto_viejo.tipo
          objeto_nuevo.correo = objeto_viejo.correo
          objeto_nuevo.save
        end
      end

      if ultimo_sitio.horario.size > 0
        ultimo_sitio.horario.each do |objeto_viejo|
          objeto_nuevo = Horario.new
          objeto_nuevo.sitio_web_id = self.id
          objeto_nuevo.seccion_id = objeto_viejo.seccion_id
          objeto_nuevo.usuario_id = objeto_viejo.usuario_id
          objeto_nuevo.dia = objeto_viejo.dia
          objeto_nuevo.hora_inicio = objeto_viejo.hora_inicio
          objeto_nuevo.hora_fin = objeto_viejo.hora_fin
          objeto_nuevo.tipo = objeto_viejo.tipo
          objeto_nuevo.aula = objeto_viejo.aula
          objeto_nuevo.save
        end
      end
    end

    unless DocenteSitioWeb.where(:sitio_web_id => self.id, :docente_id => self.usuario_id).size > 0
      self.agregar_docente_a_grupo_docente
    end
    
  end

  def correos_grupo_docente
    correo = ""
    self.docente_sitio_web.each_with_index do |docente, index|
      correo += ((correo.length==0)? "" : ",") + docente.correo
    end

    self.preparador.each_with_index do |docente, index|
      correo += ((correo.length==0)? "" : ",") + docente.correo
    end
    return correo
  end

  def correos_estudiantes
    correo = ""
    self.estudiantes.each_with_index do |estudiante, index|
      correo += ((correo.length==0)? "" : ",") + estudiante.correo
    end
    return correo
  end

  def correos
    correo = self.correos_grupo_docente
    if self.estudiantes
      correo += ((correo.length == 0)? "" : ",") + self.correos_estudiantes
    end
    return correo
  end

end
