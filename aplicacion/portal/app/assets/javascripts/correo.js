//checkbox_asignatura_carrera.change
$(function() {
  $("input[type='checkbox'].check_box_correos").change( function() {

    correo = ""
    $.each( $(".check_box_correos"), function(){
      if( ( $(this) ).is(':checked') ) {
        if ($(this).val()){
          if (correo.length >0){
            correo += ";"
          }
          correo += $(this).val()
        }
      }
      
    });

    $("#correo_correos").val(correo.replace(/;/g, ','));
  });
});

$(function() { 
  //Funcion para ingresar un comentario en un foro por AJAX
  $('#formulario_correo_enviar').submit(function(){
    $('#procesar_enviar_correo_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    if ($('#correo_correos').val()){ correos = $('#correo_correos').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    else{  correos = "";}
    
    if ($('#correo_asunto').val()){ asunto = $('#correo_asunto').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    else{  asunto = "";}
    
    if ($('#correo_texto').val()){ texto = $('#correo_texto').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    else{  texto = "";}
      
   
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { correos: correos, asunto: asunto, texto: texto},
      success: function(response) { 
        if(response.success == "ok"){
          mostrar_exito("Se ha enviado el correo exitosamente.");
          window.location = "";
        }else{
          mostrar_error(response.errores);
        }
        $('#procesar_enviar_correo_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });

});

$(function() {
  $('#correo_texto').wysihtml5({
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
