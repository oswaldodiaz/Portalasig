# -*- encoding : utf-8 -*-
class Mailer < ActionMailer::Base
  default from: "portaldesitioswebcienciasucv@gmail.com"

  def enviar_correo(correo)
    #correo.deliver
  end  

  def registro_de_usuario(usuario)
    @usuario = usuario
    @titulo = "Usted ha sido registrado exitosamente."
    @mensaje = "Para crear su clave, ingrese al portal a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias por unirse."
    #@url = url_for(controller: "inicio", action: "ingreso", only_path: false, id:, token: usuario.token)
    @url = 'inicio/ingreso?id='+usuario.id.to_s+'&token='+usuario.token.to_s
    @url_nombre = "Ingresar"
    subject = "Bienvenido al Portal de Sitios Web de Asignaturas"
    correo = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(correo)
  end

  def notificar_usuario_no_activo(usuario)
    @usuario = usuario
    @titulo = "Usted no ha activado su cuenta en el sistema todavía."
    @mensaje = "Para activar su cuenta, ingrese al portal a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."
    
    #@url = url_for(controller: "inicio", action: "ingreso", only_path: false, id: usuario.id, token: usuario.token)
    @url = 'inicio/ingreso?id='+usuario.id.to_s+'&token='+usuario.token.to_s
    @url_nombre = "Ingresar"
    subject = "Su cuenta no se encuentra activa"
    mail = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_usuario_activo(usuario)
    @usuario = usuario
    @titulo = "Usted ha activado su cuenta en el sistema exitosamente."
    @mensaje = "Ingrese al portal a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."
    @url = 'inicio/index'
    @url_nombre = "Ingresar"
    subject = "Su cuenta se ha activado exitosamente"
    mail = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_solicitud_cambio_de_clave(usuario)
    @usuario = usuario
    @titulo = "Usted ha solicitado un cambio de clave en el sistema."
    @mensaje = "Para cambiar su clave, ingrese al portal a través del siguiente enlace:"
    @mensaje_continuacion = "Si usted no solicitó este cambio de clave haga caso omiso de este correo."
    @despedida = "Gracias."
    #@url = url_for(controller: 'inicio', action: 'cambio_de_clave', only_path: false, id: @usuario.id, token: @usuario.token)
    @url = 'inicio/cambio_de_clave?id='+usuario.id.to_s+'&token='+usuario.token.to_s
    @url_nombre = "Ingresar"
    subject = "Solicitud de cambio de clave"
    mail = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_cambio_de_clave_exitoso(usuario)
    @usuario = usuario
    @titulo = "Se ha realizado el cambio de clave de su cuenta exitosamente."
    @mensaje = "Ingrese al portal a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."
    @url = 'inicio/index'
    @url_nombre = "Ingresar"
    subject = "Cambio de clave exitoso"
    mail = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_docente_nuevo(usuario)
    @usuario = usuario
    @titulo = "Usted ha sido agregado al portal de sitios web de asignaturas como docente."
    @mensaje = "Ingrese al portal a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."
    @url = 'inicio/index'
    @url_nombre = "Ingresar"
    subject = "Bienvenido al portal"
    mail = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_estudiante_nuevo(usuario)
    @usuario = usuario
    @titulo = "Usted ha sido agregado al portal de sitios web de asignaturas como estudiante."
    @mensaje = "Ingrese al portal a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."
    @url = 'inicio/index'
    @url_nombre = "Ingresar"
    subject = "Bienvenido al portal"
    mail = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_se_agrego_a_sitio_Web(usuario,sitio_web)
    @usuario = usuario
    @titulo = "Usted ha sido agregado al sitio web de la asignatura: #{sitio_web.asignatura.nombre} para el semestre #{sitio_web.periodo}."
    @mensaje = "Ingrese al sitio a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/informacion_general/index'

    @url_nombre = "Ingresar"
    subject = "Bienvenido al sitio web de la asignatura #{sitio_web.asignatura.nombre} para el semestre #{sitio_web.periodo}"

    mail = mail(:to => usuario.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_nota_a_estudiante(estudiante,docente,evaluacion,sitio_web)
    @usuario = estudiante
    @titulo = "El docente #{docente.nombre_y_apellido} ha actualizado su nota en la evaluacion: #{evaluacion.nombre} para el sitio web de la asignatura #{sitio_web.asignatura.nombre} para el semestre #{sitio_web.periodo}."
    @mensaje = "Ingrese y véala ahora a través del siguiente enlace:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/calificacion/index'

    @url_nombre = "Ingresar"
    subject = "Se ha actualizado su nota de #{sitio_web.asignatura.nombre}"

    mail = mail(:to => estudiante.correo, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_nota_a_grupo_docente(docentes,docente,evaluacion,sitio_web)
    @titulo = "El docente #{docente.nombre_y_apellido} ha actualizado las notas de la evaluacion: #{evaluacion.nombre}."
    @mensaje = "Ingrese al sitio y véalas:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/calificacion/index'

    @url_nombre = "Ingresar"
    subject = "Se han actualizado las notas de #{sitio_web.asignatura.nombre}"

    mail = mail(:to => docentes, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_creacion_de_evento(correos,sitio_web,evento)
    @titulo = "Se creó el evento #{evento.titulo}."
    @mensaje = "Ingrese al sitio y véalo en la planificación:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/planificacion/index'

    @url_nombre = "Ingresar"
    subject = "Se ha creado un evento nuevo de #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_edicion_de_evento(correos,sitio_web,evento)
    @titulo = "Se editó el evento: #{evento.titulo}."
    @mensaje = "Ingrese al sitio y véalo en la planificación:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/planificacion/index'

    @url_nombre = "Ingresar"
    subject = "Se ha editado un evento nuevo de #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_noticia_a_estudiantes(correos,sitio_web,noticia)
    @titulo = "Se ha creado una noticia nueva: #{noticia.titulo}."
    @mensaje = "Ingrese al sitio y véala en noticias:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/noticia/noticias/'+noticia.id.to_s

    @url_nombre = "Ingresar"
    subject = "Se ha creado una noticia nueva de #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_foro_nuevo(correos,autor,sitio_web, foro)
    @titulo = "#{autor.nombre_y_apellido} ha creado un nuevo foro: #{foro.titulo}."
    @mensaje = "Ingrese al sitio y conteste su duda ahora:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/foro/foros/'+foro.id.to_s

    @url_nombre = "Ingresar"
    subject = "Se ha creado un foro nuevo de #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_comentario_nuevo(correos,autor,sitio_web, comentario)
    @titulo = "#{autor.nombre_y_apellido} ha hecho un comentario en el foro: #{comentario.foro.titulo}."
    @mensaje = "Ingrese al sitio y véalo ahora:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/foro/foros/'+comentario.foro.id.to_s

    @url_nombre = "Ingresar"
    subject = "Se ha comentado el foro de #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_se_creo_entrega(correos, autor, sitio_web, entrega)
    @titulo = "#{autor.nombre_y_apellido} ha creado la entrega: #{entrega.nombre}. para el #{entrega.fecha_entrega.strftime("%d/%m/%Y")}."
    @mensaje = "Ingrese al sitio y véala ahora:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/entrega/ver_entrega/'+entrega.id.to_s

    @url_nombre = "Ingresar"
    subject = "Se ha creado una entrega nueva para #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_se_edito_entrega(correos, autor, sitio_web, entrega)
    @titulo = "#{autor.nombre_y_apellido} ha editado la entrega: #{entrega.nombre}. para el #{entrega.fecha_entrega.strftime("%d/%m/%Y")}."
    @mensaje = "Ingrese al sitio y véala ahora:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/entrega/ver_entrega/'+entrega.id.to_s

    @url_nombre = "Ingresar"
    subject = "Se ha editado una entrega para #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def notificar_descarga_nueva(correos, autor, sitio_web, descarga)
    @titulo = "#{autor.nombre_y_apellido} ha subido la descarga: #{descarga.nombre}."
    @mensaje = "Ingrese al sitio y descargala ahora:"
    @mensaje_continuacion = nil
    @despedida = "Gracias."

    @url = sitio_web.nombre_url+'/'+sitio_web.periodo+'/descarga/descargar_archivo/'+descarga.id.to_s

    @url_nombre = "Descargar"
    subject = "Se ha subido la descarga: #{descarga.nombre} para #{sitio_web.asignatura.nombre}"

    mail = mail(:to => correos, :subject => subject, :template_name => "enviar_correo")
    enviar_correo(mail)
  end

  def enviar_correo_nuevo(subject, lista_usuarios, texto, usuario)
    @descripcion = texto
    @usuario = usuario
    mail = mail(:to => lista_usuarios, :subject => subject, :template_name => "enviar_correo_sitio_web")
    enviar_correo(mail)
  end

end
