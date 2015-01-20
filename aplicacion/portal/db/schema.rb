# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131022144226) do

  create_table "administrador", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "archivo", :force => true do |t|
    t.integer  "sitio_web_id",                    :null => false
    t.string   "nombre",          :limit => 200,  :null => false
    t.string   "tipo",            :limit => 45
    t.string   "url",             :limit => 1000, :null => false
    t.string   "nombre_original", :limit => 200,  :null => false
    t.integer  "tamano",                          :null => false
    t.string   "ext",             :limit => 45,   :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "archivo", ["sitio_web_id"], :name => "archivo_sitio_web_idx"

  create_table "asignatura", :force => true do |t|
    t.string   "codigo",           :limit => 4,                          :null => false
    t.string   "nombre",           :limit => 100,                        :null => false
    t.integer  "unidades_credito",                                       :null => false
    t.string   "tipo",             :limit => 45,                         :null => false
    t.string   "requisitos",       :limit => 200, :default => "Ninguno"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  add_index "asignatura", ["codigo"], :name => "codigo_UNIQUE", :unique => true
  add_index "asignatura", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "asignatura", ["nombre"], :name => "nombre_UNIQUE", :unique => true

  create_table "asignatura_carrera", :force => true do |t|
    t.integer  "asignatura_id", :null => false
    t.integer  "carrera_id",    :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "asignatura_carrera", ["asignatura_id"], :name => "asignatura_carrera_asignatura_idx"
  add_index "asignatura_carrera", ["carrera_id"], :name => "asignatura_carrera_carrera_idx"

  create_table "asignatura_clasificacion", :force => true do |t|
    t.integer  "asignatura_id",    :null => false
    t.integer  "clasificacion_id", :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "asignatura_clasificacion", ["asignatura_id"], :name => "asignatura_clasificacion_asignatura_idx"
  add_index "asignatura_clasificacion", ["clasificacion_id"], :name => "asignatura_clasificacion_clasificacion_idx"

  create_table "asignatura_mencion", :force => true do |t|
    t.integer  "asignatura_id", :null => false
    t.integer  "mencion_id",    :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "asignatura_mencion", ["asignatura_id"], :name => "asignatura_mencion_asignatura_idx"
  add_index "asignatura_mencion", ["mencion_id"], :name => "asignatura_mencion_mencion_idx"

  create_table "bibliography", :force => true do |t|
    t.integer  "sitio_web_id",                 :null => false
    t.string   "titulo",       :limit => 200,  :null => false
    t.string   "descripcion",  :limit => 1000, :null => false
    t.string   "autores",      :limit => 200
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "bibliography", ["sitio_web_id"], :name => "bibliography_sitio_web_idx"

  create_table "bitacora", :force => true do |t|
    t.integer  "usuario_id"
    t.string   "ip",          :limit => 45,   :null => false
    t.string   "descripcion", :limit => 1000, :null => false
    t.datetime "fecha",                       :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "bitacora", ["usuario_id"], :name => "bitacora_usuario_idx"

  create_table "bitacora_sitio_web", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "calificacion", :force => true do |t|
    t.integer  "estudiante_id", :null => false
    t.integer  "evaluacion_id", :null => false
    t.float    "calificacion"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "calificacion", ["estudiante_id"], :name => "calificacion_estudiante_idx"
  add_index "calificacion", ["evaluacion_id"], :name => "calificacion_evaluacion_idx"

  create_table "carrera", :force => true do |t|
    t.string   "nombre",     :limit => 45, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "carrera", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "carrera", ["nombre"], :name => "nombre_UNIQUE", :unique => true

  create_table "clasificacion", :force => true do |t|
    t.string   "nombre",     :limit => 45, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "comentario", :force => true do |t|
    t.integer  "usuario_id",                  :null => false
    t.integer  "foro_id",                     :null => false
    t.string   "comentario", :limit => 10000, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "comentario", ["foro_id"], :name => "comentario_foro_idx"
  add_index "comentario", ["usuario_id"], :name => "comentario_usuario_idx"

  create_table "contenido_tematico", :force => true do |t|
    t.integer  "sitio_web_id",                 :null => false
    t.string   "titulo",       :limit => 100,  :null => false
    t.string   "descripcion",  :limit => 1000
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "contenido_tematico", ["sitio_web_id"], :name => "contenido_tematico_sitio_web_idx"

  create_table "docente", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "docente", ["id"], :name => "cedula_UNIQUE", :unique => true

  create_table "docente_sitio_web", :force => true do |t|
    t.integer  "docente_id",                  :null => false
    t.integer  "sitio_web_id",                :null => false
    t.integer  "seccion_id"
    t.string   "correo",       :limit => 100
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "tipo",         :limit => 45
  end

  add_index "docente_sitio_web", ["docente_id"], :name => "docente_asignatura_docente_idx"
  add_index "docente_sitio_web", ["seccion_id"], :name => "docente_sitio_web_seccion_idx"
  add_index "docente_sitio_web", ["sitio_web_id"], :name => "docente_sitio_web_idx"

  create_table "entrega", :force => true do |t|
    t.integer  "sitio_web_id",                 :null => false
    t.string   "nombre",        :limit => 100, :null => false
    t.datetime "fecha_entrega",                :null => false
    t.integer  "evento_id",                    :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "entregable", :force => true do |t|
    t.integer  "entrega_id",                      :null => false
    t.integer  "estudiante_id",                   :null => false
    t.string   "url",             :limit => 1000, :null => false
    t.string   "nombre",          :limit => 100,  :null => false
    t.string   "nombre_original", :limit => 100,  :null => false
    t.integer  "tamano",                          :null => false
    t.string   "ext",             :limit => 45,   :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "estudiante", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "estudiante", ["id"], :name => "cedula_UNIQUE", :unique => true

  create_table "estudiante_seccion_sitio_web", :force => true do |t|
    t.integer  "estudiante_id",        :null => false
    t.integer  "seccion_sitio_web_id", :null => false
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "estudiante_seccion_sitio_web", ["estudiante_id"], :name => "estudiante_seccion_estudiante_idx"
  add_index "estudiante_seccion_sitio_web", ["seccion_sitio_web_id"], :name => "estudiante_seccion_sitio_web_seccion_sitio_web_idx"

  create_table "evaluacion", :force => true do |t|
    t.integer  "sitio_web_id",                                :null => false
    t.string   "tipo",         :limit => 45
    t.string   "nombre",       :limit => 45,                  :null => false
    t.float    "valor",                      :default => 0.0
    t.datetime "fecha_inicio"
    t.datetime "fecha_fin"
    t.integer  "evento_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "evaluacion", ["sitio_web_id"], :name => "evaluacion_sitio_web_idx"

  create_table "evento", :force => true do |t|
    t.integer  "sitio_web_id",                 :null => false
    t.string   "titulo",        :limit => 45,  :null => false
    t.string   "descripcion",   :limit => 200, :null => false
    t.datetime "fecha_inicio",                 :null => false
    t.datetime "fecha_fin",                    :null => false
    t.integer  "evaluacion_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "evento", ["sitio_web_id"], :name => "evento_sitio_web_idx"

  create_table "foro", :force => true do |t|
    t.integer  "sitio_web_id",                  :null => false
    t.integer  "usuario_id",                    :null => false
    t.string   "titulo",       :limit => 200,   :null => false
    t.string   "descripcion",  :limit => 10000, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "foro", ["sitio_web_id"], :name => "foro_sitio_web_idx"
  add_index "foro", ["usuario_id"], :name => "foro_usuario_id_idx"

  create_table "horario", :force => true do |t|
    t.integer  "sitio_web_id",               :null => false
    t.integer  "seccion_id"
    t.integer  "usuario_id",                 :null => false
    t.string   "dia",          :limit => 45, :null => false
    t.integer  "hora_inicio",                :null => false
    t.integer  "hora_fin",                   :null => false
    t.string   "tipo",         :limit => 45, :null => false
    t.string   "aula",         :limit => 45
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "horario", ["seccion_id"], :name => "horario_seccion_id_idx"
  add_index "horario", ["sitio_web_id"], :name => "horario_sitio_web_idx"
  add_index "horario", ["usuario_id"], :name => "horario_usuario_id_idx"

  create_table "mencion", :force => true do |t|
    t.string   "nombre",     :limit => 45, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "mencion", ["nombre"], :name => "nombre_UNIQUE", :unique => true

  create_table "mencion_carrera", :force => true do |t|
    t.integer  "mencion_id", :null => false
    t.integer  "carrera_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "mencion_carrera", ["carrera_id"], :name => "mencion_carrerar_carrerra_idx"
  add_index "mencion_carrera", ["mencion_id"], :name => "mencion_carrerra_mencion_idx"

  create_table "notice", :force => true do |t|
    t.integer  "sitio_web_id",                :null => false
    t.string   "titulo",       :limit => 45,  :null => false
    t.string   "noticia",      :limit => 200, :null => false
    t.integer  "usuario_id",                  :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "notice", ["sitio_web_id"], :name => "notice_sitio_web_idx"
  add_index "notice", ["usuario_id"], :name => "notice_usuario_idx"

  create_table "objetivo", :force => true do |t|
    t.integer  "sitio_web_id",                 :null => false
    t.string   "descripcion",  :limit => 1000, :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "objetivo", ["sitio_web_id"], :name => "objetivo_sitio_web_idx"

  create_table "planificacion", :force => true do |t|
    t.integer  "sitio_web_id",                :null => false
    t.integer  "semana",                      :null => false
    t.string   "titulo",       :limit => 45,  :null => false
    t.string   "descripcion",  :limit => 200, :null => false
    t.datetime "fecha",                       :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "planificacion", ["sitio_web_id"], :name => "planificacion_sitio_web_idx"

  create_table "preparador", :force => true do |t|
    t.integer  "estudiante_id",                :null => false
    t.integer  "sitio_web_id",                 :null => false
    t.integer  "seccion_id"
    t.string   "tipo",          :limit => 45
    t.string   "correo",        :limit => 100
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "preparador", ["estudiante_id"], :name => "preparador_estudiante_idx"
  add_index "preparador", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "preparador", ["seccion_id"], :name => "preparador_seccion_idx"
  add_index "preparador", ["sitio_web_id"], :name => "preparador_sitio_web_idx"

  create_table "seccion", :force => true do |t|
    t.string   "nombre",        :limit => 10, :null => false
    t.integer  "asignatura_id",               :null => false
    t.integer  "semestre_id",                 :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "seccion", ["id"], :name => "id_UNIQUE", :unique => true

  create_table "seccion_sitio_web", :force => true do |t|
    t.integer  "seccion_id",   :null => false
    t.integer  "sitio_web_id", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "seccion_sitio_web", ["seccion_id"], :name => "seccion_sitio_web_seccion__idx"
  add_index "seccion_sitio_web", ["sitio_web_id"], :name => "seccion_sitio_web_sitio_web_idx"

  create_table "semestre", :force => true do |t|
    t.string   "periodo_academico", :limit => 2, :null => false
    t.integer  "ano_lectivo",                    :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "session", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "session", ["session_id"], :name => "index_session_on_session_id"
  add_index "session", ["updated_at"], :name => "index_session_on_updated_at"

  create_table "sitio_web", :force => true do |t|
    t.integer  "asignatura_id", :null => false
    t.integer  "semestre_id",   :null => false
    t.integer  "usuario_id",    :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "sitio_web", ["asignatura_id"], :name => "sitio_web_asignatura_idx"
  add_index "sitio_web", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "sitio_web", ["semestre_id"], :name => "asdfasdf_idx"
  add_index "sitio_web", ["usuario_id"], :name => "odsijfslkd_idx"

  create_table "usuario", :force => true do |t|
    t.integer  "cedula",                                   :null => false
    t.string   "clave",      :limit => 200,                :null => false
    t.string   "nombre",     :limit => 45,                 :null => false
    t.string   "apellido",   :limit => 45,                 :null => false
    t.string   "correo",     :limit => 45,                 :null => false
    t.string   "token",      :limit => 200,                :null => false
    t.integer  "activo",                    :default => 0, :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "usuario", ["cedula"], :name => "cedula_UNIQUE", :unique => true
  add_index "usuario", ["correo"], :name => "correo_UNIQUE", :unique => true
  add_index "usuario", ["token"], :name => "token_UNIQUE", :unique => true

end
