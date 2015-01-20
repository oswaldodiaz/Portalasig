$(function() {
  $.each($('.entrega_fecha'), function(){
    $(this).datepicker({
      dateformat: 'dd/mm/yy',
      changeMonth: true,
      changeYear: true,
      minDate: 0,
      yearRange: "0:+1"
    });

    $(this).datepicker($.datepicker.regional['es']);
  });
});

//Formulario para agregar asignatura por docente
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#formulario_agregar_entrega').submit(function(){
    $('#agregar_entrega_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    nombre = "";
    fecha_entrega = "";
    fecha_tope = "";

    if($('#entrega_nombre').val()){ nombre = $('#entrega_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#entrega_fecha_entrega').val()){ fecha_entrega = $('#entrega_fecha_entrega').val().replace(/"/g, '').replace(/'/g, '');}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { nombre: nombre, fecha_entrega: fecha_entrega },
      success: function(response) {
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado la entrega exitosamente.");
        }else{
          mostrar_error(response.errores);
          $('#agregar_entrega_submit').removeAttr('disabled');
          $('#ajax-loader').hide();
        }
      }
    });
    return false;
  });
});

//Formulario para agregar asignatura por docente
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#formulario_editar_entrega').submit(function(){
    $('#editar_entrega_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    id = "";
    nombre = "";
    fecha_entrega = "";

    if($('#entrega_id').val()){ id = $('#entrega_id').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#entrega_nombre').val()){ nombre = $('#entrega_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#entrega_fecha_entrega').val()){ fecha_entrega = $('#entrega_fecha_entrega').val().replace(/"/g, '').replace(/'/g, '');}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: id, nombre: nombre, fecha_entrega: fecha_entrega },
      success: function(response) {
        if(response.success == "ok"){
          mostrar_exito("Se ha editado la entrega exitosamente.");
        }else{
          mostrar_error(response.errores);
          $('#editar_entrega_submit').removeAttr('disabled');
          $('#ajax-loader').hide();
        }
      }
    });
    return false;
  });
});