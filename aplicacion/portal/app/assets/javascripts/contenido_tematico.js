/*###############################     Contenido Tematico   ###################################*/

// Esta función agrega una fila para agregar un contenido tematico nuevo al editar
$(function() { 
  return $('#agregar_contenido_tematico_button').click(function() {
    $('#contenido_tematico_cantidad').val( parseInt( $('#contenido_tematico_cantidad').val() ) + 1 );
    cant = $('#contenido_tematico_cantidad').val();
    
    texto = '<tr id = "'+cant+'" class="contenido_tematico_contenido_tematico"> <td style = "vertical-align:top;padding-right:10px;" id = "contenido_tematico_numero_tema_'+cant+'"><b> Tema # '+cant+'</b></td>';
    texto += '</tr><tr id = "titulo_'+cant+'"><td style = "padding-bottom:5px;">';
    texto += '<textarea id = "contenido_tematico_titulo_'+cant+'" name = "contenido_tematico[titulo_'+cant+']" ';
    texto += 'class = "text_area_long" style = "width: 500px;height: 30px;" placeholder = "Título"/></td>';
    texto += '<td style = "vertical-align:top;padding-left:10px;"><a href="#" id = "eliminar_contenido_tematico_'+cant+'"';
    texto +='onclick = "eliminar_contenido_tematico_tabla(this.id);return false;"><i class = "icon-trash"/></a></td></tr>';
    texto +='<tr id="descripcion_'+cant+'"><td style = "padding-bottom:10px;"><textarea id = "contenido_tematico_descripcion_'+cant+'"name = "contenido_tematico[descripcion_'+cant+']" ';
    texto +='class = "text_area_long" style = "width: 500px;height: 60px;" placeholder = "Descripción"/></td></tr>';

   
    $('#tbody_agregar_contenido_tematico').append(texto);
    $('#contenido_tematico_titulo_'+cant).autoResize();
    $('#contenido_tematico_descripcion_'+cant).autoResize();

  });
});

function eliminar_contenido_tematico_tabla(thisid){
  id_array = thisid.split("_")
  id = id_array[id_array.length-1]
  $('#'+id).remove();
  $('#titulo_'+id).remove();
  $('#descripcion_'+id).remove();

  $('#contenido_tematico_cantidad').val( parseInt( $('#contenido_tematico_cantidad').val() ) - 1 );
  cant = $('#contenido_tematico_cantidad').val();

  for(i = id; i <= cant; i++){
    $("#"+(parseInt(i)+1)).empty().append('<td><b>Tema # '+i+'</b></td>');
    $("#"+(parseInt(i)+1)).attr('id', i);
    
    
    $("#titulo_"+(parseInt(i)+1)).attr('id', "titulo_"+i);
    $("#descripcion_"+(parseInt(i)+1)).attr('id', "descripcion_"+i);

    $("#contenido_tematico_titulo_"+(parseInt(i)+1)).attr('name', 'contenido_tematico[titulo_'+i+"]");
    $("#contenido_tematico_titulo_"+(parseInt(i)+1)).attr('id', 'contenido_tematico_titulo_'+i);

    $("#contenido_tematico_descripcion_"+(parseInt(i)+1)).attr('name', 'contenido_tematico[descripcion_'+i+"]");
    $("#contenido_tematico_descripcion_"+(parseInt(i)+1)).attr('id', 'contenido_tematico_descripcion_'+i);

    $("#eliminar_contenido_tematico_"+(parseInt(i)+1)).attr('id', 'eliminar_contenido_tematico_'+i);
  }
}



//Esta funcion envia el formulario via AJAX para agilizar la respuesta con el servidor
$(function() { 
  //Funcion para enviar los datos del contenido tematico por AJAX
  $('#formulario_editar_contenido_tematico').submit(function(){
    $('#editar_contenido_tematico_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    
    contenidos_tematicos = [];
    cant = $('#contenido_tematico_cantidad').val();

    for(i = 1; i <= cant; i++){
      if ($('#contenido_tematico_titulo_'+i).val()){ titulo = $('#contenido_tematico_titulo_'+i).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      else{  titulo = "";}

      if ($('#contenido_tematico_descripcion_'+i).val()){ descripcion = $('#contenido_tematico_descripcion_'+i).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      else{  descripcion = "";}

      contenidos_tematicos[i-1] = '{"titulo":"'+titulo+'","descripcion":"'+descripcion+'"}';

    }

    $.ajax({
       type: "POST",
       data: {contenidos_tematicos: contenidos_tematicos},
       url: $(this).attr('action'),
       success: function(response){
        if(response.success == "ok"){
          mostrar_exito("Se guardó el contenido temático exitosamente.");
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_contenido_tematico_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
       }
    });
    return false;
  });

});
