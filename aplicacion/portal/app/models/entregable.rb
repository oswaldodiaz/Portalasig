class Entregable < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :entrega
  belongs_to :estudiante

  before_destroy "eliminar_archivo_entregable"

  def eliminar_archivo_entregable
    if File.exist? self.url
      FileUtils.rm self.url
    end
  end

  def imagen
    case self.ext
    when "xls"
      return "excel.png"
    when "xlsx"
      return "excel.png"
    when "doc"
      return "word.png"
    when "docx"
      return "word.png"
    when "ppt"
      return "powerpoint.png"
    when "pptx"
      return "powerpoint.png"
    when "pdf"
      return "pdf.png"
    when "c++"
      return "c++.png"
    when "c"
      return "c++.png"
    when "java"
      return "java.png"
    when "zip"
      return "zip.png"
    when "tar"
      return "tar.png"
    when "rar"
      return "rar.png"
    else
      return "file.png"
    end

    return "file.png"
  end

  def tamano_string
    if self.tamano.to_i < 1024
      return self.tamano.to_s + " B"
    elsif self.tamano.to_i < 1048576
      return (self.tamano.to_i/1024).to_i.to_s + " KB"
    else
      return (self.tamano.to_i/1048576).to_i.to_s + " MB"
    end        
  end

  def seccion
    return seccion_nombre = Seccion.where(:id => 
            SeccionSitioWeb.where(:sitio_web_id => self.entrega.sitio_web.id, :id => 
              EstudianteSeccionSitioWeb.where(:estudiante_id => self.estudiante.id).collect{|x| x.seccion_sitio_web_id}
            ).collect{|x| x.seccion_id}
          ).first.nombre
  end
end
