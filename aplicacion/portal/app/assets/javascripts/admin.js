/*################################## COMUNES ##################################*/
$(function() {
  $(".li_agregar").click(function(){
    if( $(this).attr('id') == 'li_agregar_uno' ){
      $('#li_agregar_lista').parent().removeClass();
      $("#div_agregar_lista").hide();

      $("#div_agregar_uno").show();
      $('#li_agregar_uno').parent().addClass('active');
    }else{

      $('#li_agregar_uno').parent().removeClass();
      $("#div_agregar_uno").hide();

      $("#div_agregar_lista").show();
      $('#li_agregar_lista').parent().addClass('active');
    }
    return false;
  });
});




/*###################################Usuarios###################################*/
$(function() { 
  return $('#usuario_cedula').blur(function() {
  	cedula = $('#usuario_cedula').val();

    if( $('#url') ){
      url_array = $('#url').attr('href').split("/");

      url = "";
      admin = false;
      estudiantes = false;

      for(i = 0; i < url_array.length; i++){
        if(url_array[i] == "admin"){ admin = true; break;}
        if(url_array[i] == "estudiantes"){ estudiantes = true; break;}
      }

      if(admin){
        for(i = 0; i < url_array.length; i++){
          if(url_array[i] == "admin"){ break;}
          if(i > 0){ url += "/";}
          url += url_array[i];
        }
      }else{
        if(estudiantes){
          for(i = 0; i < url_array.length-3; i++){
            if(i > 0){ url += "/";}
            url += url_array[i];
          }
        }
      }

      if(url != ""){
        if(cedula != ""){
          $.ajax({
        	  url: url+'/ajax/buscar_usuario_por_cedula/?cedula='+cedula,
        	  success: function(usuario) {
        	    if (usuario){
        	      $('#usuario_nombre').val(usuario.nombre);
        	      $('#usuario_apellido').val(usuario.apellido);
        	      $('#usuario_correo').val(usuario.correo);
        	    }
        	  }
          });
        }
      }
    }
  });
});

/*###################################DOCENTES###################################*/
//buscar docente
$(function() {
  $("#buscar_docente_submit").click( function() {
    estudiante = $("#docente_datos").val();

    url_array = $(this).attr('href').split("/");
    url = "";
    for(i = 0; i < url_array.length; i++){
      if(url_array[i] == "admin"){ break;}
      if(i > 0){ url += "/";}
      url += url_array[i];
    }

    url_redirect = url+"/admin/docente/"+estudiante;
    url += "/ajax/buscar_docente_por_cedula_y_nombre/"

    if(estudiante != ""){
      $("#imagen_de_carga").show();
      $.ajax({
        type: "POST",
        url: url+estudiante,
        success: function(response) {
          if(response.success == "ok"){
            window.location = url_redirect;
          }else{
            mostrar_error(response.errores);
            $("#imagen_de_carga").hide();
          }
        }
      });
    }

    return false;
  });
});


$(function() { 
  return $('#docentes_check_box').click(function() {
  	cant = $('#docentes_cantidad').val();
  	if ($('#docentes_check_box').is(':checked')){
  		for(var i = 1; i <= cant; i++){
  			$('#docente_check_box_'+i).prop('checked', true);
  		}
  		$('#eliminar_docentes_button').show();
	}else{
  		for(var i = 1; i <= cant; i++){
  			$('#docente_check_box_'+i).prop('checked', false);
  		}
  		$('#eliminar_docentes_button').hide();
	}
  });
});

$(function() {
	$("input[type='checkbox']").change( function() {
		if($(this).attr('id') != "docentes_check_box"){
			cant = $('#docentes_cantidad').val();
			if( ( $(this) ).is(':checked') ) {

				$('#eliminar_docentes_button').show();

				for(var i = 1; i <= cant; i++){
					if( !(( $('#docente_check_box_'+i) ).is(':checked')) ) {
						return;
					}
				}
				$('#docentes_check_box').prop('checked', true);
				
			}else{
				$('#docentes_check_box').prop('checked', false);

				for(var i = 1; i <= cant; i++){
					if( ( $('#docente_check_box_'+i) ).is(':checked') ) {
						return;
					}
				}
				$('#eliminar_docentes_button').hide();
			}
		}
	});
});


//Formulario para agregar docente
$(function() { 
  //Funcion para agregar los estudiantes por AJAX
  $('#formulario_agregar_docente').submit(function(){
    $('#agregar_docente_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    if ($('#usuario_cedula').val()){ cedula = $('#usuario_cedula').val().replace(/"/g, '').replace(/'/g, '');}
    else{  cedula = "";}

    if ($('#usuario_nombre').val()){ nombre = $('#usuario_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    else{  nombre = "";}

    if ($('#usuario_apellido').val()){ apellido = $('#usuario_apellido').val().replace(/"/g, '').replace(/'/g, '');}
    else{  apellido = "";}

    if ($('#usuario_correo').val()){ correo = $('#usuario_correo').val().replace(/"/g, '').replace(/'/g, '');}
    else{  correo = "";}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { cedula: cedula, nombre: nombre, apellido: apellido, correo: correo},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado al docente exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#agregar_docente_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});


//Formulario para editar docente
$(function() { 
  //Funcion para agregar los estudiantes por AJAX
  $('#formulario_editar_docente').submit(function(){
    $('#editar_docente_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    if ($('#usuario_id').val()){ id = $('#usuario_id').val().replace(/"/g, '').replace(/'/g, '');}
    else{  id = "";}

    if ($('#usuario_cedula').val()){ cedula = $('#usuario_cedula').val().replace(/"/g, '').replace(/'/g, '');}
    else{  cedula = "";}

    if ($('#usuario_nombre').val()){ nombre = $('#usuario_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    else{  nombre = "";}

    if ($('#usuario_apellido').val()){ apellido = $('#usuario_apellido').val().replace(/"/g, '').replace(/'/g, '');}
    else{  apellido = "";}

    if ($('#usuario_correo').val()){ correo = $('#usuario_correo').val().replace(/"/g, '').replace(/'/g, '');}
    else{  correo = "";}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: id, cedula: cedula, nombre: nombre, apellido: apellido, correo: correo},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha editado al docente exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_docente_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});



/*###################################ESTUDIANTES###################################*/
//buscar ESTUDIANTE
$(function() {
  $("#buscar_estudiante_submit").click( function() {
    estudiante = $("#estudiante_datos").val();

    url_array = $(this).attr('href').split("/");
    url = "";
    for(i = 0; i < url_array.length; i++){
      if(url_array[i] == "admin"){ break;}
      if(i > 0){ url += "/";}
      url += url_array[i];
    }

    url_redirect = url+"/admin/estudiante/"+estudiante;
    url += "/ajax/buscar_estudiante_por_cedula_y_nombre/"

    if(estudiante != ""){
      $("#imagen_de_carga").show();
      $.ajax({
        type: "POST",
        url: url+estudiante,
        success: function(response) {
          if(response.success == "ok"){
            window.location = url_redirect;
          }else{
            mostrar_error(response.errores);
            $("#imagen_de_carga").hide();
          }
        }
      });
    }

    return false;
  });
});


$(function() {
  $("input[type='checkbox'].check_box_estudiantes_admin").change( function() {
    if($(this).attr('id') == "estudiantes_check_box"){
      cant = $('#estudiantes_cantidad').val();
      if ($('#estudiantes_check_box').is(':checked')){
        for(var i = 1; i <= cant; i++){
          $('#estudiante_check_box_'+i).prop('checked', true);
        }
        $('#eliminar_estudiantes_button').show();
      }else{
          for(var i = 1; i <= cant; i++){
            $('#estudiante_check_box_'+i).prop('checked', false);
          }
          $('#eliminar_estudiantes_button').hide();
      }
    }else{

      cant = $('#estudiantes_cantidad').val();
      if( ( $(this) ).is(':checked') ) {

        $('#eliminar_estudiantes_button').show();

        for(var i = 1; i <= cant; i++){
          if( !(( $('#estudiante_check_box_'+i) ).is(':checked')) ) {
            return;
          }
        }
        $('#estudiantes_check_box').prop('checked', true);
        
      }else{
        $('#estudiantes_check_box').prop('checked', false);

        for(var i = 1; i <= cant; i++){
          if( ( $('#estudiante_check_box_'+i) ).is(':checked') ) {
            return;
          }
        }
        $('#eliminar_estudiantes_button').hide();
      }
    }
  });
});

//Formulario para agregar estudiante
$(function() { 
  //Funcion para agregar los estudiantes por AJAX
  $('#formulario_agregar_estudiante').submit(function(){
    $('#agregar_estudiante_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    if ($('#usuario_cedula').val()){ cedula = $('#usuario_cedula').val().replace(/"/g, '').replace(/'/g, '');}
    else{  cedula = "";}

    if ($('#usuario_nombre').val()){ nombre = $('#usuario_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    else{  nombre = "";}

    if ($('#usuario_apellido').val()){ apellido = $('#usuario_apellido').val().replace(/"/g, '').replace(/'/g, '');}
    else{  apellido = "";}

    if ($('#usuario_correo').val()){ correo = $('#usuario_correo').val().replace(/"/g, '').replace(/'/g, '');}
    else{  correo = "";}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { cedula: cedula, nombre: nombre, apellido: apellido, correo: correo},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado al estudiante exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#agregar_estudiante_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});

//Formulario para editar estudiante
$(function() { 
  //Funcion para agregar los estudiantes por AJAX
  $('#formulario_editar_estudiante').submit(function(){
    $('#editar_estudiante_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    if ($('#usuario_id').val()){ id = $('#usuario_id').val().replace(/"/g, '').replace(/'/g, '');}
    else{  id = "";}

    if ($('#usuario_cedula').val()){ cedula = $('#usuario_cedula').val().replace(/"/g, '').replace(/'/g, '');}
    else{  cedula = "";}

    if ($('#usuario_nombre').val()){ nombre = $('#usuario_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    else{  nombre = "";}

    if ($('#usuario_apellido').val()){ apellido = $('#usuario_apellido').val().replace(/"/g, '').replace(/'/g, '');}
    else{  apellido = "";}

    if ($('#usuario_correo').val()){ correo = $('#usuario_correo').val().replace(/"/g, '').replace(/'/g, '');}
    else{  correo = "";}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: id, cedula: cedula, nombre: nombre, apellido: apellido, correo: correo},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado al estudiante exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_estudiante_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});

/*###################################ASIGNATURAS###################################*/
//buscar_asignatura
$(function() {
  $("#buscar_asignatura_submit").click( function() {
    asignatura = $("#asignatura_datos").val();

    url_array = $(this).attr('href').split("/");
    url = "";
    controlador = "";
    for(i = 0; i < url_array.length; i++){
      if(url_array[i] == "inicio" || url_array[i] == "admin"){
        controlador = url_array[i];
        break;
      }
      if(i > 0){ url += "/";}
      url += url_array[i];
    }

    url_redirect = url+"/"+ controlador +"/asignatura/"+asignatura;
    url += "/ajax/buscar_asignatura_por_codigo_y_nombre/"

    if(asignatura != ""){
      $("#imagen_de_carga").show();
      $.ajax({
        type: "POST",
        url: url+asignatura,
        success: function(response) {
          if(response.success == "ok"){
            window.location = url_redirect;
          }else{
            mostrar_error(response.errores);
            $("#imagen_de_carga").hide();
          }
        }
      });
    }

    return false;
  });
});


$(function() { 
  return $('checkbox.asignaturas_check_box').click(function() {
  	cant = $('#asignaturas_cantidad').val();
  	if ($('#asignaturas_check_box').is(':checked')){
  		for(var i = 1; i <= cant; i++){
  			$('#asignatura_check_box_'+i).prop('checked', true);
  		}
  		$('#eliminar_asignaturas_button').show();
	}else{
  		for(var i = 1; i <= cant; i++){
  			$('#asignatura_check_box_'+i).prop('checked', false);
  		}
  		$('#eliminar_asignaturas_button').hide();
	}
  });
});

$(function() {
	$("input[type='checkbox'].check_box_asignaturas").change( function() {
    id_array = $(this).attr('id').split("_");
    id = id_array[4];
    
		if(id_array[3] == "todos"){
      car = id_array[4];
      cant = $('#asignaturas_cantidad_'+car).val();
      if ($('#asignaturas_check_box_todos_'+car).is(':checked')){
        for(var i = 1; i <= cant; i++){
          $('#asignatura_check_box_'+car+'_'+i).prop('checked', true);
        }
        $('#eliminar_asignaturas_button').show();
      }else{
        for(var i = 1; i <= cant; i++){
          $('#asignatura_check_box_'+car+'_'+i).prop('checked', false);
        }
        $('#eliminar_asignaturas_button').hide();
      }
			
    }else{
      car = id_array[3];
      cant = $('#asignaturas_cantidad_'+car).val();
			if( ( $(this) ).is(':checked') ) {

				$('#eliminar_asignaturas_button').show();

				for(var i = 1; i <= cant; i++){
					if( !(( $('#asignatura_check_box_'+car+'_'+i) ).is(':checked')) ) {
						return;
					}
				}
				$('#asignaturas_check_box_todos_'+car).prop('checked', true);
				
			}else{
				$('#asignaturas_check_box_todos_'+car).prop('checked', false);

				for(var i = 1; i <= cant; i++){
					if( ( $('#asignatura_check_box_'+car+'_'+i) ).is(':checked') ) {
						return;
					}
				}
				$('#eliminar_asignaturas_button').hide();
			}
		}
	});
});


//Formulario para agregar asignatura por administrador
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#formulario_agregar_asignatura_administrador').submit(function(){
    $('#agregar_asignatura_administrador_submit').attr('disabled','disabled');
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
          mostrar_exito("Se guardó la asignatura satisfactoriamente.");
          //redireccionar("/inicio/asignatura/",response.params);
        }else{
          mostrar_error(response.errores);
        }
        $('#agregar_asignatura_administrador_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });
});

//Formulario para editar asignatura por administrador
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#formulario_editar_asignatura_administrador').submit(function(){
    $('#editar_asignatura_administrador_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    id = "";
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

    if($('#asignatura_id').val()){ id = $('#asignatura_id').val().replace(/"/g, '').replace(/'/g, '');}
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
        id: id, codigo: codigo, nombre: nombre, carreras: carreras, unidades_credito: unidades_credito, 
        clasificacion: clasificacion, tipo: tipo, requisitos: requisitos 
      },
      success: function(response) {
        if(response.success == "ok"){
          mostrar_exito("Se guardó la asignatura satisfactoriamente.");
          //redireccionar("/inicio/asignatura/",response.params);
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_asignatura_administrador_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });
});

