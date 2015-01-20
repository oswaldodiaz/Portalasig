$(function() { 
  //Funcion para ingresar un comentario en un foro por AJAX
  $('#formulario_foro_nuevo').submit(function(){
    $('#procesar_crear_foro_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    titulo = $('#foro_titulo').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');
    texto = $('#foro_texto').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');
    
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { titulo: titulo, texto: texto},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado el foro exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#procesar_crear_foro_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});

$(function() { 
  //Funcion para ingresar un comentario en un foro por AJAX
  $('#formulario_comentario').submit(function(){
    $('#publicar_comentario_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    foro_id = $('#foro_id').val();
    comentario = $('#comentario_comentario').val();
    
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: foro_id, comentario: comentario},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha agregado el comentario exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#publicar_comentario_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});

$(function() {
  $('#foro_texto').wysihtml5({
    "font-styles": false, //Font styling, e.g. h1, h2, etc. Default true
    "emphasis": true, //Italics, bold, etc. Default true
    "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
    "html": false, //Button which allows you to edit the generated HTML. Default false
    "link": true, //Button to insert a link. Default true
    "image": false, //Button to insert an image. Default true,
    "color": false, //Button to change color of font
    locale: "es-AR"
  });
});

$(function() {
  $('#comentario_comentario').wysihtml5({
    "font-styles": false, //Font styling, e.g. h1, h2, etc. Default true
    "emphasis": true, //Italics, bold, etc. Default true
    "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
    "html": false, //Button which allows you to edit the generated HTML. Default false
    "link": true, //Button to insert a link. Default true
    "image": false, //Button to insert an image. Default true,
    "color": false, //Button to change color of font
    locale: "es-AR"
  });
});