$(function() {
  $('#agregar_objetivo_button').click(function() {
    $('#objetivo_cantidad').val( parseInt( $('#objetivo_cantidad').val() ) + 1 );
    cant = $('#objetivo_cantidad').val();

    texto = '<tr id='+cant+'><td id="objetivo_numero_'+cant+'" style = "vertical-align:top;padding-right:10px;">'+cant
    texto += '</td><td style = "padding-bottom:10px;"><textarea id = "objetivo_objetivo_'+cant
    texto += '" name = "objetivo[objetivo_'+cant
    texto += ']" class = "objetivo" style = "resize:none;width: 550px;" placeholder="Descripción"/>'
    texto += '</td><td style = "vertical-align:top;padding-left:10px;"><a href="#" id="eliminar_objetivo_'+cant
    texto += '" onclick = "eliminar_objetivo_tabla(this.id);return false;" ><i class="icon-trash"/></a></td></tr>';

    $('#tbody_agregar_objetivo').append(texto);
    $('#objetivo_objetivo_'+cant).autoResize();
  });
});

$(function() {
  $('#formulario_editar_objetivos').submit(function(){
    $('#editar_objetivos_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    objetivos = [];

    cant = $('#objetivo_cantidad').val();
    for(i = 1; i <= cant; i++){
      if ($('#objetivo_objetivo_'+i).val()){ objetivos[i-1] = $('#objetivo_objetivo_'+i).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      else{  objetivos[i-1] = "";}
    };

    $.ajax({
       type: "POST",
       data: {objetivos: objetivos},
       url: $(this).attr('action'),
       success: function(response){
        if(response.success == "ok"){
          mostrar_exito("Se guardaron los objetivos exitosamente.");
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_objetivos_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
       }
    });
    return false;
  });

});

function eliminar_objetivo_tabla(thisid){
  id_array = thisid.split("_")
  id = id_array[id_array.length-1];
  $('#'+id).remove();
  $('#objetivo_cantidad').val( parseInt( $('#objetivo_cantidad').val() ) - 1 );
  cant = $('#objetivo_cantidad').val();

  for(i = id; i <= cant; i++){
    $("#"+(parseInt(i)+1)).attr('id', i);

    $("#objetivo_numero_"+(parseInt(i)+1)).text(i);

    $("#objetivo_numero_"+(parseInt(i)+1)).attr('id', "objetivo_numero_"+i);

    $("#objetivo_objetivo_"+(parseInt(i)+1)).attr('name', 'objetivo[objetivo_'+i+"]");
    $("#objetivo_objetivo_"+(parseInt(i)+1)).attr('id', 'objetivo_objetivo_'+i);

    $("#eliminar_objetivo_"+(parseInt(i)+1)).attr('id', 'eliminar_objetivo_'+i);
    
  }

  return false;
}  