$(function() { 
  //Funcion que cambia los campos de las notas
  $('.button_editar_calificaciones_evaluacion').click(function(){
    $(this).parent().click();
    $(this).hide();
    id_array = $(this).attr('id').split("_");
    eval = id_array[id_array.length-2];
    sec = id_array[id_array.length-1];

    i = 0;
    $.each($('.calificacion_evaluacion_'+eval+'_'+sec), function(){
      $('#evaluacion_'+eval+'_'+sec+'_calificacion_'+i).hide();
      if($('#calificacion_'+eval+'_'+sec+'_'+i).val() != ""){
        $('#calificacion_'+eval+'_'+sec+'_'+i).val(parseFloat($('#calificacion_'+eval+'_'+sec+'_'+i).val().replace(",", ".")));
      }
      $('#editar_evaluacion_'+eval+'_'+sec+'_calificacion_'+i).show();

      i++;
    });

    $('#button_cancelar_calificaciones_evaluacion_'+eval+'_'+sec).show();
    $('#submit_editar_calificaciones_evaluacion_'+eval+'_'+sec).show();

    return false;
  });
});


$(function() { 
  //Funcion que cambia los campos de las notas
  $('.button_cancelar_calificaciones_evaluacion').click(function(){
    $(this).hide();
    id_array = $(this).attr('id').split("_");
    eval = id_array[id_array.length-2];
    sec = id_array[id_array.length-1];

    i = 0;
    $.each($('.calificacion_evaluacion_'+eval+'_'+sec), function(){
      $('#editar_evaluacion_'+eval+'_'+sec+'_calificacion_'+i).hide();
      $('#evaluacion_'+eval+'_'+sec+'_calificacion_'+i).show();
      i++;
    });

    $('#button_editar_calificaciones_evaluacion_'+eval+'_'+sec).show();
    $('#submit_editar_calificaciones_evaluacion_'+eval+'_'+sec).hide();

    return false;
  });
});


//Esta funcion envia el formulario via AJAX para agilizar la repsuesta con el servidor
$(function() { 
  //Funcion para enviar los datos del contenido tematico por AJAX
  $('.formulario_editar_calificacion').submit(function(){
    id_array = $(this).attr('id').split("_");
    eval = id_array[id_array.length-2];
    sec = id_array[id_array.length-1];

    $('#submit_editar_calificaciones_evaluacion_'+eval+'_'+sec).attr('disabled','disabled');
    $( '#p_editar_calificaciones_evaluacion_'+eval+'_'+sec ).children( "#ajax-loader" ).show();
    
    evaluacion_id = "";
    if( $('#evaluacion_id_'+eval).val() ){  evaluacion_id = $('#evaluacion_id_'+eval).val();}

    calificaciones = []
    i = 0;
    $.each($('.calificacion_evaluacion_'+eval+'_'+sec), function(){
      estudiante_id = "";
      nota = "";
      
      if( $('#estudiante_'+eval+'_'+sec+'_'+i).val() ){  estudiante_id = $('#estudiante_'+eval+'_'+sec+'_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if( $('#calificacion_'+eval+'_'+sec+'_'+i).val() ){  nota =$('#calificacion_'+eval+'_'+sec+'_'+i).val().replace(/"/g, '').replace(/'/g, '');}

      calificaciones[i] = '{"estudiante_id":"'+estudiante_id+'","nota":"'+nota+'"}';
      i++;
    });

    $.ajax({
       type: "POST",
       data: {evaluacion_id: evaluacion_id, calificaciones: calificaciones},
       url: $(this).attr('action'),
       success: function(response){

        $('#submit_editar_calificaciones_evaluacion_'+eval+'_'+sec).removeAttr('disabled');
        $( '#p_editar_calificaciones_evaluacion_'+eval+'_'+sec ).children( "#ajax-loader" ).hide();
        if(response.success == "ok"){
          mostrar_exito("Se guardaron las calificaciones exitosamente.");

          i = 0;
          $.each($('.calificacion_evaluacion_'+eval+'_'+sec), function(){
            if($('#calificacion_'+eval+'_'+sec+'_'+i).val()){
              $('#evaluacion_'+eval+'_'+sec+'_calificacion_'+i).text(parseFloat($('#calificacion_'+eval+'_'+sec+'_'+i).val().replace(",", ".")));
            }else{
              if($('#evaluacion_'+eval+'_'+sec+'_calificacion_'+i).text() != "-"){
                $('#evaluacion_'+eval+'_'+sec+'_calificacion_'+i).text("-");
              }
            }
            i++;
          });

          $('.button_cancelar_calificaciones_evaluacion').click();
          $('#descargar_evaluaciones_button').show();

        }else{
          mostrar_error(response.errores);
        }
       }
    });
    return false;
  });
});