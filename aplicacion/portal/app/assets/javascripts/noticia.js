$(function() { 
  //Funcion para enviar un correo al olvidar clave por AJAX
  $('#formulario_noticia').submit(function(){
    $('#procesar_crear_noticia_submit').attr('disabled','disabled');
    $( "#ajax-loader" ).show();
    titulo = $('#noticia_titulo').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');
    noticia = $('#noticia_texto').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { titulo: titulo, noticia: noticia},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado la noticia exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#procesar_crear_noticia_submit').removeAttr('disabled');
        $( "#ajax-loader" ).hide();
      }
    });
    return false;
  });

});

