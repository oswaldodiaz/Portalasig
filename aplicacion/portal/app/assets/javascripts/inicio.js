/***************************** Funciones de Validacion *********************/
function es_un_numero(texto){
  if ( texto.match(/^[0-9]+$/) ){  return true; }
  return false;
}

function es_un_codigo_de_asignatura(texto){
  if( es_un_numero(texto) && texto.length == 4 ){ return true;}
  return false;
}

function cambiar_id_modal_nuevo_sitio_web(id){
  $('#modal_asignatura_id ').val(id);
  url = $('#buscar_semestres_disponibles_para_asignatura_por_id').attr('href')+'?id='+id;

  return $.ajax({
    url: url,
    success: function(semestres) {
      if(semestres.length > 0){
  
        var $select = $("#semestre_semestre");
        $select.empty(); // remove old options
        
        $.each(semestres, function(i,semestre){
          periodo = semestre.periodo_academico + "-" + parseInt(semestre.ano_lectivo);
          $select.append($("<option></option>").attr("value", periodo).text(periodo));
          i++;
        });
      }
    }
  });
}




/**************************** Funciones de inicio de sesion ***********************/
//Funcion de inicio de sesion
$(function() { 
  //Funcion que envia los datos del formulario de inicio de sesion por ajax
  $('#formulario_inicio_sesion').submit(function(){
    $('#error_iniciar_sesion').hide();
    $('#iniciar_sesion_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    cedula = "";
    clave = "";
    if($('#modal_usuario_cedula').val()){ cedula = $('#modal_usuario_cedula').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#modal_usuario_clave').val()){ clave = $('#modal_usuario_clave').val().replace(/"/g, '').replace(/'/g, '');}
    
    $('#modal_usuario_cedula').val("");
    $('#modal_usuario_clave').val("");

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { cedula: cedula, clave: clave },
      success: function(response) { 
        if(response.success == "ok"){
          $('#cerrar_modal').click();
          $('#url').removeAttr('href');
          url = "";
          
          if(response.admin == "true"){
            url = $('#inicio_sesion_url').attr('href')+"admin/asignaturas"
          }
          mostrar_exito("Inicio de sesión exitoso");
          window.location = url

        }else{
          $('#error_iniciar_sesion').show();
          $("#error_iniciar_sesion").attr('class', 'alert alert-error');
          $('#flash_iniciar_sesion').empty();
          $('#flash_iniciar_sesion').text("La cédula y/o clave es incorrecta. Inténtelo nuevamente.");
        }
        $('#iniciar_sesion_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });
});

//Funcion de activaciond usuario
$(function() { 
  //Funcion para enviar los datos del formulario de activacion de usuario por AJAX  
  $('#formulario_activacion_de_usuario').submit(function(){
    $('#activar_usuario_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    id = "";
    token = "";
    clave = "";
    confirmacion = "";

    if($('#usuario_id').val()){ id = $('#usuario_id').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_token').val()){ token = $('#usuario_token').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_clave').val()){ clave = $('#usuario_clave').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_confirmacion').val()){ confirmacion = $('#usuario_confirmacion').val().replace(/"/g, '').replace(/'/g, '');}

    $('#usuario_clave').val("");
    $('#usuario_confirmacion').val("");

    url_array = $(this).attr('action').split("/");
    url = "";
    for(i = 0; i < url_array.length; i++){
      if(url_array[i] == "inicio"){ break;}
      if(i > 0){ url += "/";}
      url += url_array[i];
    }

    url_redirect = url+"/inicio/index";

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: id, token: token, clave: clave, confirmacion: confirmacion },
      success: function(response) { 
        if(response.success == "ok"){
          window.location = url_redirect;
        }else{
          mostrar_error(response.errores);
        }
        $('#activar_usuario_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });
});

//Formulario para cambiar clave
$(function() { 
  //Funcion para enviar los datos del formulario de cambio de clave de usuario por AJAX
  $('#formulario_procesar_cambiar_clave').submit(function(){
    $('#guardar_clave_nueva_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    id = "";
    clave_actual = "";
    clave_nueva = "";
    confirmacion = "";

    if($('#usuario_id').val()){ id = $('#usuario_id').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_clave_actual').val()){ clave_actual = $('#usuario_clave_actual').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_clave_nueva').val()){ clave_nueva = $('#usuario_clave_nueva').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_confirmacion').val()){ confirmacion = $('#usuario_confirmacion').val().replace(/"/g, '').replace(/'/g, '');}
    
    $('#usuario_clave_actual').val("");
    $('#usuario_clave_nueva').val("");
    $('#usuario_confirmacion').val("");

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: id, clave_actual: clave_actual, clave_nueva: clave_nueva, confirmacion: confirmacion },
      success: function(response) {
        if(response.success == "ok"){
          mostrar_exito("Se ha cambiado la clave exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#guardar_clave_nueva_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});

//Formulario recuperar clave
$(function() { 
  //Funcion para enviar los datos del formulario de cambio de clave de usuario por AJAX
  $('#formulario_recuperar_clave').submit(function(){
    $('#guardar_nueva_clave_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    id = "";
    token = "";
    clave_nueva = "";
    confirmacion = "";

    if($('#usuario_id').val()){ id = $('#usuario_id').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_token').val()){ token = $('#usuario_token').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_clave_nueva').val()){ clave_nueva = $('#usuario_clave_nueva').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#usuario_confirmacion').val()){ confirmacion = $('#usuario_confirmacion').val().replace(/"/g, '').replace(/'/g, '');}

    $('#usuario_clave_nueva').val("");
    $('#usuario_confirmacion').val("");

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: id, token: token, clave_nueva: clave_nueva, confirmacion: confirmacion },
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se realizó el cambio de clave exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#guardar_nueva_clave_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});

//Formulario olvido de clave
$(function() { 
  //Funcion para enviar un correo al olvidar clave por AJAX
  $('#formulario_olvido_clave').submit(function(){
    $('#enviar_correo_olvido_clave_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    cedula = "";
    if($('#usuario_cedula').val()){ cedula = $('#usuario_cedula').val().replace(/"/g, '').replace(/'/g, '');}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { cedula: cedula },
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se le ha enviado un correo para que pueda recuperar su clave.")
        }else{
          mostrar_error(response.errores);
        }
        $('#enviar_correo_olvido_clave_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});




/***************************** Funciones de asignatura *****************************/

menciones = [];

function actualizar_menciones_un_select(i){
  cant = $('#cantidad_menciones').val();

  valor = $('#asignatura_mencion_'+i).val();

  var $select = $('#asignatura_mencion_'+i);
  $select.empty(); // remove old options
  $select.append($("<option></option>").text("Seleccione"));

  for(j = 0; j < menciones.length; j++){
    $select.append($("<option></option>").attr("value", menciones[j]).text(menciones[j]));
  }

  $select.append($("<option></option>").attr("value", "Otra").text("Otra"));

  $( "#asignatura_mencion_otra_"+i ).autocomplete({ source: menciones });
}

function actualizar_menciones(){
  cant = $('#cantidad_menciones').val();
  for(i = 1; i <= cant; i++){
    valor = $('#asignatura_mencion_'+i).val();

    var $select = $('#asignatura_mencion_'+i);
    $select.empty(); // remove old options
    $select.append($("<option></option>").text("Seleccione"));


    for(j = 0; j < menciones.length; j++){
      $select.append($("<option></option>").attr("value", menciones[j]).text(menciones[j]));
    }

    $select.append($("<option></option>").attr("value", "Otra").text("Otra"));

    if(valor != "" && valor != null){
      if(valor == "Otra"){
        $( "#asignatura_mencion_otra_"+i ).show();
      }else{
        $("select#asignatura_mencion_"+i+ " option").filter(function() {
          return $(this).text() == valor;
        }).attr('selected', true);
        $( "#asignatura_mencion_otra_"+i ).hide();
      }
    }
      
    
    $( "#asignatura_mencion_otra_"+i ).autocomplete({ source: menciones });

  }
}


//checkbox_asignatura_carrera.change
$(function() {
  $("input[type='checkbox'].carreras").change( function() {
    if($(this).val() == "Complementaria"){
      $.each($("input[type='checkbox'].carreras"), function(){
        if( ( $(this) ).is(':checked') && $(this).val() != "Complementaria" ){
          $( $(this) ).prop('checked', false);
        }
      });

      if($('#asignatura_tipo')){
        $('#asignatura_tipo').val("Complementaria");
        $('#asignatura_tipo').change();
      }else{
        if($('#informacion_general_tipo')){
          $('#informacion_general_tipo').val("Complementaria");
          $('#informacion_general_tipo').change();
        }
      }


    }else{
      $("input[type='checkbox'][value='Complementaria'].carreras").prop('checked', false);
    
      

      if($('#asignatura_tipo')){
        if($('#asignatura_tipo').val() == "Complementaria"){
          $('#asignatura_tipo').val("Otra");
        }
      }else{
        if($('#informacion_general_tipo')){
          if($('#informacion_general_tipo').val() == "Complementaria"){
            $('#informacion_general_tipo').val("Otra");
          }
        }
      }

      carreras = [];
      cant = $('#carreras_cantidad').val();
      j = 0;
      for(i = 1; i <= cant; i++){
        if( ( $('#check_box_carrera_'+i) ).is(':checked') ) {
          carreras[j] = '{"carrera":"'+$('#check_box_carrera_'+i).val().replace(/"/g, '').replace(/'/g, '')+'"}';
          j++;
        }
      }

      url_array = $("#url").attr('href').split("/");
      url = "";
      for(i = 0; i < url_array.length; i++){
        if(url_array[i] == "inicio" || url_array[i] == "admin"){break;}
        if(i > 0){ url += "/";}
        url += url_array[i];
      }

      url += "/ajax/buscar_menciones_por_carreras/"

      if(carreras.length > 0){
        $.ajax({
          type: "POST",
          url: url,
          data: { carreras: carreras},
          success: function(response) {
            if(response.menciones){
              for(i = 0; i < response.menciones.length; i++){
                menciones[i] = response.menciones[i].nombre;
              }
              actualizar_menciones();
            }else{
              menciones = [];
              actualizar_menciones();
            }
          }
        });
      }else{
        menciones = [];
        actualizar_menciones();
      }
    }
  });
});


//asignatura_tipo.change
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#asignatura_tipo').change(function(){
    tipo = $('#asignatura_tipo').val();

    $('#clasificacion').show();
    $('#tipo_obligatoria').hide();
    $('#tipo_electiva').hide();

    if(tipo == "Obligatoria"){
      $('#tipo_obligatoria').show();
      $('#clasificacion_texto').empty().append("<b>Semestre (*):</b>");
    }else{
      if(tipo == "Electiva" || tipo == "Obligatoria optativa"){
        $('#tipo_electiva').show();
        $('#clasificacion_texto').empty().append("<b>Mención (*):</b>");
      }else{
        $('#clasificacion').hide();
      }
    }
  });

});



//.asignatura_mencion.change
function asignatura_mencion_otra(thisid){
  id = thisid.split("_");
  mencion = $('#asignatura_mencion_'+id[id.length-1]).val();

  if(mencion == "Otra"){
    $('#asignatura_mencion_otra_'+id[id.length-1]).show();
  }else{
    $('#asignatura_mencion_otra_'+id[id.length-1]).hide();
  }
}


//Agregar mencion
$(function() { 
  $('#agregar_mencion_a_asignatura_button').click(function(){
    $('#cantidad_menciones').val( parseInt( $('#cantidad_menciones').val() ) + 1 );
    cant = $('#cantidad_menciones').val();

    p =  '<p id="p_mencion_'+cant+'">';
    p += '<select class="asignatura_mencion" id="asignatura_mencion_'+cant+'" name="asignatura[mencion_'+cant+']" onchange="asignatura_mencion_otra(this.id)"><option value="Otra">Otra</option></select>';
    p += '<input id="asignatura_mencion_otra_'+cant+'" name="asignatura[mencion_otra_'+cant+']" placeholder="Mención" style="display:';
    p += 'none;width: 200px;margin-left: 4px;" type="text"><a href="#" id="eliminar_mencion_a_asignatura_button_'+cant+'" class="btn" title="Eliminar ';
    p += 'mención" onclick="eliminar_mencion_de_la_tabla_asignatura_nueva(this.id);return false;" style="margin-left: 4px;"><i class="icon-trash"></i></a></p>';

    $('#tipo_electiva').append(p);

    actualizar_menciones_un_select(cant);

    $('#asignatura_mencion_otra_'+cant).hide();

  });
});

// Esta función elimina una fila en editar docente
function eliminar_mencion_de_la_tabla_asignatura_nueva(thisid){

  id_array = thisid.split("_")
  id = id_array[id_array.length-1]
  $('#p_mencion_'+id).remove();

  
  $('#cantidad_menciones').val( parseInt( $('#cantidad_menciones').val() ) - 1 );
  cant = $('#cantidad_menciones').val();

  for(i = id; i <= cant; i++){
    //tr inicial
    $("#p_mencion_"+(parseInt(i)+1)).attr('id', 'p_mencion_'+i);

    $("#asignatura_mencion_"+(parseInt(i)+1)).attr('name', 'asignatura[mencion_'+i+']');
    $("#asignatura_mencion_"+(parseInt(i)+1)).attr('id', 'asignatura_mencion_'+i);

    $("#asignatura_mencion_otra_"+(parseInt(i)+1)).attr('name', 'asignatura[mencion_otra_'+i+']');
    $("#asignatura_mencion_otra_"+(parseInt(i)+1)).attr('id', 'asignatura_mencion_otra_'+i);

    $("#eliminar_mencion_a_asignatura_button_"+(parseInt(i)+1)).attr('id', 'eliminar_mencion_a_asignatura_button_'+i);

  }

}

//Formulario para agregar asignatura por docente
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#formulario_agregar_asignatura_docente').submit(function(){
    $('#agregar_asignatura_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    codigo = "";
    nombre = "";
    carreras = [];
    unidades_credito = "";
    tipo = "";
    clasificacion = "";
    requisitos = "";

    cant = $('#carreras_cantidad').val();
    j = 0;
    for(i = 1; i <= cant; i++){
      if( ( $('#check_box_carrera_'+i) ).is(':checked') ) {
        carreras[j] = '{"carrera":"'+$('#check_box_carrera_'+i).val().replace(/"/g, '').replace(/'/g, '')+'"}';
        j++;

      }
    }

    if($('#asignatura_codigo').val()){ codigo = $('#asignatura_codigo').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#asignatura_nombre').val()){ nombre = $('#asignatura_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#asignatura_unidades_credito').val()){ unidades_credito = $('#asignatura_unidades_credito').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#asignatura_requisitos').val()){ requisitos = $('#asignatura_requisitos').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if($('#asignatura_tipo').val()){ tipo = $('#asignatura_tipo').val().replace(/"/g, '').replace(/'/g, '');}

    if(tipo == "Obligatoria"){
      if($('#asignatura_clasificacion_obligatoria').val()){ 
        clasificacion = $('#asignatura_clasificacion_obligatoria').val().replace(/"/g, '').replace(/'/g, '');
      }
    }else{
      if(tipo == "Electiva" || tipo == "Obligatoria optativa"){
        
        clasificacion = []
        cant = $('#cantidad_menciones').val();
        
        for(i = 1; i <= cant; i++){

          if( $('#asignatura_mencion_'+i).val() ) {

            clasificacion[i-1] = ""
            if( $('#asignatura_mencion_'+i).val() == "Otra" ) {
              if( $('#asignatura_mencion_otra_'+i).val() ) {
                clasificacion[i-1] = '{"clasificacion":"'+$('#asignatura_mencion_otra_'+i).val().replace(/"/g, '').replace(/'/g, '')+'"}';
              }else{
                clasificacion[i-1] = '{"clasificacion":""}';
              }

            }else{
              if( $('#asignatura_mencion_'+i).val() == "Seleccione" ){
                clasificacion[i-1] = '{"clasificacion":""}';;
              }else{
                clasificacion[i-1] = '{"clasificacion":"'+$('#asignatura_mencion_'+i).val().replace(/"/g, '').replace(/'/g, '')+'"}';
              }
              
            }

                        
          }else{
            clasificacion[i-1] = '{"clasificacion":""}';
          }

        }

      }
    }

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { 
        codigo: codigo, nombre: nombre, carreras: carreras, unidades_credito: unidades_credito, 
        clasificacion: clasificacion, tipo: tipo, requisitos: requisitos 
      },
      success: function(response) {
        if(response.success == "ok"){
          $('#url').val( response.url );
          mostrar_exito("Se guardó la asignatura satisfactoriamente.");
          //redireccionar("/inicio/asignatura/",response.params);
        }else{
          mostrar_error(response.errores);
        }
        $('#agregar_asignatura_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });
});

//Reemplazar datos de asignatura existente
$(function() { 
  return $('#asignatura_codigo').blur(function() {
    codigo = $('#asignatura_codigo').val();

    url_array = $('#url').attr('href').split("/");

    url = "";
    for(i = 0; i < url_array.length; i++){
      if(url_array[i] == "inicio" || url_array[i] == "admin"){ break;}
      if(i > 0){ url += "/";}
      url += url_array[i];
    
    } 

    if(es_un_codigo_de_asignatura(codigo)){
      $.ajax({
        url: url+'/ajax/buscar_asignatura_por_codigo?codigo='+codigo,
        success: function(asignatura) {
          if (asignatura.nombre){
            cantidad_menciones = $('#cantidad_menciones').val();
            for(l = 2; l <= cantidad_menciones; l++){
              eliminar_mencion_de_la_tabla_asignatura_nueva('eliminar_mencion_a_asignatura_button_2')
            }
            $.each($('input[type=checkbox].carreras'), function(){
              $(this).attr("checked",false);
            });

            for(i = 0; i < asignatura.carrera.length; i++){
              $(":checkbox").filter(function() {
                  return this.value == asignatura.carrera[0].nombre;
              }).prop("checked", "true");
            }

            for(i = 0; i < asignatura.menciones.length; i++){
              menciones[i] = asignatura.menciones[i].nombre;
            }
            actualizar_menciones();

            if(asignatura.tipo == "Electiva" || asignatura.tipo == "Obligatoria optativa"){
              if(asignatura.clasificacion.length > 0){

                for(k = 0; k < asignatura.clasificacion.length; k++){
                  if(k > 0){ 
                    $('#agregar_mencion_a_asignatura_button').click();
                  }

                  $("select#asignatura_mencion_"+(parseInt(k)+1)+ " option").filter(function() {
                      //may want to use $.trim in here
                      return $(this).text() == asignatura.clasificacion[k].nombre;
                  }).attr('selected', true);
                  $("#asignatura_mencion_otra_"+(parseInt(k)+1)).hide();
                }
              }
            }


            $('#asignatura_nombre').val(asignatura.nombre);
            $('#asignatura_unidades_credito').val(asignatura.unidades_credito);
            $('#asignatura_requisitos').val(asignatura.requisitos);

            $('#asignatura_tipo').val(asignatura.tipo);

            $('#clasificacion').show();
            $('#tipo_obligatoria').hide();
            $('#tipo_electiva').hide();

            if(asignatura.tipo == "Obligatoria"){
              $('#tipo_obligatoria').show();

              $('#asignatura_clasificacion_obligatoria').val(asignatura.clasificacion);
            }else{
              if(asignatura.tipo == "Electiva" || asignatura.tipo == "Obligatoria optativa"){
                $('#tipo_electiva').show();
              }else{
                $('#clasificacion').hide();
              }
            }

          }
        }
      });
    }
  });
});