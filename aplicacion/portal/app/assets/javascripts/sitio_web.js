$(function() { 
  $("form").submit(function(){
    $("#mensajes").hide();
  });
});

$(function() { 
  $(".eliminar_mensaje").click(function(){
    $(this).parent().hide();
  });
});

function mostrar_error(errores){
  $('#mensajes').hide();
  if(errores != null){
    $('#mensajes').show();
    $("#mensajes").attr('class', 'alert alert-error');
    $('#flash').empty();
    if(errores.length > 1){
      mensaje = "<ul>Se cometieron los siguientes errores:";
      $.each(errores, function(i,error){
        mensaje += "<li>"+error.error+"</li>";
      });
      mensaje += "</ul>";
      $('#flash').append(mensaje);
    }else{
      $('#flash').text(errores[0].error);
    }

  }
}

function mostrar_mensaje(mensaje){
  $('#mensajes').hide();
  if(mensaje != null){
    $('#mensajes').show();
    $("#mensajes").attr('class', 'alert alert-info');
    $('#flash').text(mensaje);
  }
}

function mostrar_exito(exito){
  $('#mensajes').hide();
  if(exito != null){
    $('#mensajes').show();
    $("#mensajes").attr('class', 'alert alert-success');
    $('#flash').text(exito);
    if($('#url').attr('href')) {
      window.location = $('#url').attr('href');
    }
  }
}

function redireccionar(url,params){
  url += "?"
  $.each(params, function(key,value){
    url += key + "=" + value + "&"
  });
  url = url.substring(0, url.length - 1);
  window.location = url;
  mostrar_exito("La asignatura ha sido agregada exitosamente.");
}


$(function() { 
  return $('.parrafo_que_se_puede_eliminar').hover(function() {
    $( $(this).children()[0] ).children('.enlace_de_parrafo_que_se_puede_eliminar').show();
  });
});

$(function() { 
  return $('.enlace_de_parrafo_que_se_puede_eliminar').mouseout(function() {
    $(this).hide();
  });
});

$(function() { 
  return $('#p_para_eliminar').click(function() {
    $(this).parent().remove();
  });
});


$(function() { 
  $('textarea').autoResize();
});


//Enviar un mensaje a traves de un formulario para que se muestre en la vista index apropiada
function enviar_mensaje_exito(mensaje){
  mostrar_exito(mensaje);
  if($('#url').val() && mensaje)
    $('<form action="'+$('#url').val()+'" method="POST">' + 
    '<input type="hidden" name="mensaje" value="' + mensaje + '">' +
    '</form>').submit();
}

$(function() { 
  $('input[type=submit]').click(function() { 
    $.blockUI({ 
      message: 'Cargando. Espere un momento por favor...',
      css: { 
        border: 'none', 
        padding: '15px', 
        backgroundColor: '#000', 
        '-webkit-border-radius': '10px', 
        '-moz-border-radius': '10px', 
        opacity: .5, 
        color: '#fff'
      } 
    });

  }); 

  $(document).ajaxStop($.unblockUI);
}); 