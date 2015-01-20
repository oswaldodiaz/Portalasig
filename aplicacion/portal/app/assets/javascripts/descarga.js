/*###############################     Descaragas   ###################################*/

// Esta función agrega una fila para descargas
$(function() { 
  return $('#agregar_descarga_button').click(function() {
    $('#cantidad_archivos').val( parseInt( $('#cantidad_archivos').val() ) + 1 );
    cant = $('#cantidad_archivos').val();
    
    row_nombre = '<div class="row-fluid" id="row_nombre_'+cant+'" style="padding-bottom:10px">';
    
    nombre_div = '<div class="span" style="text-align:left;width:620px">';
    nombre_strong = '<strong>Nombre (*):</strong>';
    
    nombre_input =  '<input id="archivo_nombre_'+cant+'" name="archivo[nombre_'+cant+']" placeholder="Nombre para ';
    nombre_input += 'mostrar" size="30" style="width: 500px;margin-left:10px" type="text">';

    nombre_enlace = '<a href="#" id="eliminar_descarga_'+cant+'" onclick="eliminar_descarga_tabla(this.id);';
    nombre_enlace += 'return false;"><i class="icon-trash"></i></a>';
                
    nombre = row_nombre+nombre_div+nombre_strong+nombre_input+nombre_enlace+'</div></div>';
    

    row_archivo = '<div class="row-fluid" id="row_archivo_'+cant+'" style="padding-bottom:20px">';

    archivo_select = '<div class="span" style="text-align:left;width:200px">';
    archivo_select += '<strong>Tipo (*):</strong>';
    archivo_select += '<select id="archivo_tipo_'+cant+'" name="archivo[tipo_'+cant+']" style="width:';
    archivo_select += '100px;margin-left:10px"><option value="">Seleccione</option>';
    archivo_select += '<option value="Exámenes">Exámenes</option>';
    archivo_select += '<option value="Guías">Guías</option>';
    archivo_select += '<option value="Laboratorio">Laboratorio</option>';
    archivo_select += '<option value="Proyectos">Proyectos</option>';
    archivo_select += '<option value="Taller">Taller</option>';
    archivo_select += '<option value="Teoría">Teoría</option>';
    archivo_select += '<option value="Práctica">Práctica</option>';
    archivo_select += '<option value="Otros">Otros</option></select></div>';

    archivo_archivo = '<div class="span" style="margin-left:20px;width:400px"><input accept="xls/xlsx/ods" id="';
    archivo_archivo += 'archivo_a_subir_'+cant+'" name="archivo_a_subir_'+cant+'" style="width:400px" type="file"></div>';

    archivo = row_archivo+archivo_select+archivo_archivo+'</div>';

    $('#descargas').append(nombre+archivo);


  });
});

function eliminar_descarga_tabla(thisid){
  id_array = thisid.split("_")
  id = id_array[id_array.length-1]
  $('#row_nombre_'+id).remove();
  $('#row_archivo_'+id).remove();

  $('#cantidad_archivos').val( parseInt( $('#cantidad_archivos').val() ) - 1 );
  cant = $('#cantidad_archivos').val();

  for(i = id; i <= cant; i++){
    $("#row_nombre_"+(parseInt(i)+1)).attr('id', 'row_nombre_'+i);
    $("#row_archivo_"+(parseInt(i)+1)).attr('id', 'row_archivo_'+i);
    

    $("#archivo_nombre_"+(parseInt(i)+1)).attr('name', 'archivo[nombre_'+i+"]");
    $("#archivo_nombre_"+(parseInt(i)+1)).attr('id', 'archivo_nombre_'+i);

    $("#archivo_tipo_"+(parseInt(i)+1)).attr('name', 'archivo[tipo_'+i+"]");
    $("#archivo_tipo_"+(parseInt(i)+1)).attr('id', 'archivo_tipo_'+i);

    $("#archivo_a_subir_"+(parseInt(i)+1)).attr('name', 'archivo_a_subir_'+i);
    $("#archivo_a_subir_"+(parseInt(i)+1)).attr('id', 'archivo_a_subir_'+i);

    $("#eliminar_descarga_"+(parseInt(i)+1)).attr('id', 'eliminar_descarga_'+i);
  }
}


//Esta funcion envia el formulario via AJAX para agilizar la repsuesta con el servidor
$(function() { 
  //Funcion para enviar los datos del contenido tematico por AJAX
  $('#formulario_agregar_descarga').submit(function(){
    $('#agregar_descarga_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    
    cant = $('#cantidad_archivos').val();
    errores = [];
    j = 0;

    for(i = 1; i <= cant; i++){
      if( $('#archivo_nombre').val() == "" ){
        errores[j] = "Debe ingresar el nombre a mostrar del archivo.";
        j++;
      }

      if( $('#archivo_tipo').val() == "" ){
        errores[j] = "Debe seleccionar el tipo de archivo.";
        j++;
      }

      if( $('#archivo_a_subir').val() == "" ){
        errores[j] = "Debe seleccionar el archivo a subir.";
        j++;
      }
    }


    if(errores.size > 0){ 
      mostrar_error(errores);

      $('#agregar_descarga_submit').removeAttr('disabled');
      $('#ajax-loader').hide();
      return false;
    }

  });

});
