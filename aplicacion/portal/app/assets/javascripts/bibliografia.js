/*###############################     BIBLIOGRAFIA    ###################################*/

// Esta función agrega una fila para agregar una bibliografia nuevo al editar
$(function() { 
  return $('#agregar_bibliografia_button').click(function() {
    $('#bibliography_cantidad').val( parseInt( $('#bibliography_cantidad').val() ) + 1 );
    cant = $('#bibliography_cantidad').val();

    texto = '<tr id = "'+cant+'" class="bibliografia"><td><b>Bibliografía #'+cant+'</b></td></tr>';
    texto += '<tr id="autores_'+cant+'"><td style = "padding-bottom:5px;padding-right:10px;"><input type ="text" id = ';
    texto += '"bibliography_autores_'+cant+'" name = "bibliography[autores_'+cant+']" class = "text_area_long" style = "width: 500px;"';
    texto += ' placeholder = "Autores"/></td><td style = "vertical-align:top;padding-left:10px;"><a id="eliminar_bibliography_'+cant+'" href="#"';
    texto += ' onclick = "eliminar_bibliography_tabla(this.id);return false;"><i class = "icon-trash"/></a></td></tr><tr id="titulo_'+cant+'">';
    texto += '<td style = "padding-bottom:5px;"><textarea id = "bibliography_titulo_'+cant+'" name = "bibliography[titulo_'+cant;
    texto += ']" class = "text_area_long" style = "width: 500px;" placeholder = "Título"/></td></tr><tr id="descripcion_'+cant+'">';
    texto += '<td style = "padding-bottom:15px;"><textarea id = "bibliography_descripcion_'+cant+'" name = "bibliography';
    texto += '[descripcion_'+cant+']" class = "text_area_long" style = "width: 500px;" placeholder = "Descripción"/>';
    texto += '</td></tr>';

    $('#tbody_agregar_bibliografia').append(texto);
    $('#bibliography_titulo_'+cant).autoResize();
    $('#bibliography_descripcion_'+cant).autoResize();
  });
});

// Esta función elimina una fila en editar la bibliografia
function eliminar_bibliography_tabla(thisid){
  id_array = thisid.split("_")
  id = id_array[id_array.length-1]
  $('#'+id).remove();
  $('#autores_'+id).remove();
  $('#titulo_'+id).remove();
  $('#descripcion_'+id).remove();

  $('#bibliography_cantidad').val( parseInt( $('#bibliography_cantidad').val() ) - 1 );
  cant = $('#bibliography_cantidad').val();

  for(i = id; i <= cant; i++){
    $("#"+(parseInt(i)+1)).empty().append('<td><b>Bibliografía #'+i+'</b></td>');
    $("#"+(parseInt(i)+1)).attr('id', i);
    
    $("#autores_"+(parseInt(i)+1)).attr('id', "autores_"+i);
    $("#titulo_"+(parseInt(i)+1)).attr('id', "titulo_"+i);
    $("#descripcion_"+(parseInt(i)+1)).attr('id', "descripcion_"+i);

    $("#bibliography_autores_"+(parseInt(i)+1)).attr('name', 'bibliography[autores_'+i+"]");
    $("#bibliography_autores_"+(parseInt(i)+1)).attr('id', 'bibliography_autores_'+i);

    $("#bibliography_titulo_"+(parseInt(i)+1)).attr('name', 'bibliography[titulo_'+i+"]");
    $("#bibliography_titulo_"+(parseInt(i)+1)).attr('id', 'bibliography_titulo_'+i);

    $("#bibliography_descripcion_"+(parseInt(i)+1)).attr('name', 'bibliography[descripcion_'+i+"]");
    $("#bibliography_descripcion_"+(parseInt(i)+1)).attr('id', 'bibliography_descripcion_'+i);

    $("#eliminar_bibliography_"+(parseInt(i)+1)).attr('id', 'eliminar_bibliography_'+i);
  }
}




$(function() { 
  //Funcion para agregar una bibliografia por AJAX
  $('#formulario_editar_bibliografia').submit(function(){
    $('#editar_bibliografia_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    bibliografias = [];
    
    cant = $('#bibliography_cantidad').val();

    for(i = 1; i <= cant; i++){
      autor = "";
      titulo = "";
      descripcion = "";

      if($('#bibliography_autores_'+i).val()){  autor = $('#bibliography_autores_'+i).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      if($('#bibliography_titulo_'+i).val()){  titulo = $('#bibliography_titulo_'+i).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      if($('#bibliography_descripcion_'+i).val()){  descripcion = $('#bibliography_descripcion_'+i).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}

      bibliografias[i-1] = '{"autor":"'+autor+'","titulo":"'+titulo+'","descripcion":"'+descripcion+'"}';
    };

    $.ajax({
       type: "POST",
       data: {bibliografias: bibliografias},
       url: $(this).attr('action'),
       success: function(response){
        if(response.success == "ok"){
          mostrar_exito("Se guardó la bibliografía exitosamente.");
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_bibliografia_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
       }
    });
    return false;
  });

});