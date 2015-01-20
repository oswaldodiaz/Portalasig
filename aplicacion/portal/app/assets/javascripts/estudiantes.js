/*###################################ESTUDIANTES###################################*/
$(function() {
	$("input[type='checkbox'].check_box_estudiantes").change( function() {
    id = $(this).attr('id');

    padre = $(this).parent().attr('id').split("_");

    if(padre[2] == "todos"){
      seccion = padre[padre.length-1];
      cant = $('#seccion_sitio_web_cantidad_'+seccion).val();

      if( ( $(this) ).is(':checked') ) {
        
        for(var i = 1; i <= cant; i++){
          $('#check_box_estudiante_seccion_'+seccion+'_'+i).prop('checked', true);
        }
        $('#button_eliminar_estudiantes_seccion_sitio_web_'+seccion).show();

      }else{

        for(var i = 1; i <= cant; i++){
          $('#check_box_estudiante_seccion_'+seccion+'_'+i).prop('checked', false);
        }
        $('#button_eliminar_estudiantes_seccion_sitio_web_'+seccion).hide();
      }

    }else{

      if(padre[2] == "elementos"){
        seccion = padre[padre.length-1];
        cant = $('#seccion_sitio_web_cantidad_'+seccion).val();

        if( ( $(this) ).is(':checked') ) {
          $('#button_eliminar_estudiantes_seccion_sitio_web_'+seccion).show();

          for(var i = 1; i <= cant; i++){
            if( !(( $('#check_box_estudiante_seccion_'+seccion+'_'+i) ).is(':checked')) ) {
              return;
            }
          }

          $('#check_box_estudiante_seccion_sitio_web_'+seccion).prop('checked', true);
          
        }else{
          $('#check_box_estudiante_seccion_sitio_web_'+seccion).prop('checked', false);

          for(var i = 1; i <= cant; i++){
            if( ( $('#check_box_estudiante_seccion_'+seccion+'_'+i) ).is(':checked') ) {
              return;
            }
          }

          $('#button_eliminar_estudiantes_seccion_sitio_web_'+seccion).hide();
        }
      }
    }
	});
});


$(function() { 
  //Funcion para agregar los estudiantes por AJAX
  $('#formulario_agregar_estudiante_a_seccion_sitio_web').submit(function(){
    $('#agregar_estudiante_seccion_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    if ($('#seccion_sitio_web_id').val()){ seccion_sitio_web_id = $('#seccion_sitio_web_id').val().replace(/"/g, '').replace(/'/g, '');}
    else{  seccion_sitio_web_id = "";}

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
      data: { seccion_sitio_web_id: seccion_sitio_web_id, cedula: cedula, nombre: nombre, apellido: apellido, correo: correo},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado al estudiante exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#agregar_estudiante_seccion_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});
