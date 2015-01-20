/***************************** Funciones de asignatura *****************************/
function actualizar_menciones_informacion_general(id){

  menciones = [];
  i = 0;
  $("#informacion_general_mencion_1 option").each(function(){
    if($(this).val() != ""){
      menciones[i] = $(this).val();
      i++;
    }
  });
    
  var $select = $('#'+id);
  $select.empty(); // remove old options
  $select.append($("<option></option>").text("Seleccione"));

  for(j = 0; j < menciones.length; j++){
    $select.append($("<option></option>").attr("value", menciones[j]).text(menciones[j]));
  }
  
  $( "#informacion_general_mencion_otra_"+id.split("_")[3] ).autocomplete({ source: menciones });

}

//asignatura_tipo.change
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#informacion_general_tipo').change(function(){
    tipo = $('#informacion_general_tipo').val();

    $('#informacion_general_clasificaciones').show();
    $('#informacion_general_tipo_obligatoria').hide();
    $('#informacion_general_tipo_electiva').hide();

    if(tipo == "Obligatoria"){
      $('#informacion_general_tipo_obligatoria').show();
      $('#clasificacion_texto').empty().append("<b>Semestre (*):</b>");
    }else{
      if(tipo == "Electiva" || tipo == "Obligatoria optativa"){
        $('#informacion_general_tipo_electiva').show();
        $('#clasificacion_texto').empty().append("<b>Mención (*):</b>");
      }else{
        $('#informacion_general_clasificaciones').hide();
      }
    }
  });

});



//.asignatura_mencion.change
function mencion_otra_informacion_general(thisid){
  id = thisid.split("_");
  mencion = $('#informacion_general_mencion_'+id[id.length-1]).val();

  if(mencion == "Otra"){
    $('#informacion_general_mencion_otra_'+id[id.length-1]).show();
  }else{
    $('#informacion_general_mencion_otra_'+id[id.length-1]).hide();
  }
}


//Agregar mencion
$(function() { 
  $('#agregar_mencion_a_asignatura_informacion_general_button').click(function(){

    $('#informacion_general_cantidad_menciones').val( parseInt( $('#informacion_general_cantidad_menciones').val() ) + 1 );
    cant = $('#informacion_general_cantidad_menciones').val();

    p =  '<p id="p_mencion_informacion_general_'+cant+'">';
    p += '<select id="informacion_general_mencion_'+cant+'" name="informacion_general[mencion_'+cant+']" onchange="mencion_otra_informacion_general(this.id)"></select>';
    p += '<input id="informacion_general_mencion_otra_'+cant+'" name="informacion_general[mencion_otra_'+cant+']" placeholder="Mención" style="display:';
    p += 'none;width: 185px;margin-left: 4px;" type="text"><a href="#" id="eliminar_mencion_a_informacion_general_button_'+cant+'" class="btn" title="Eliminar ';
    p += 'mención" onclick="eliminar_mencion_de_la_tabla_informacion_general_nueva(this.id);return false;" style="margin-left: 4px;"><i class="icon-trash"></i></a></p>';

    $('#informacion_general_tipo_electiva').append(p);

    actualizar_menciones_informacion_general("informacion_general_mencion_"+cant);
  });
});

// Esta función elimina una fila en editar docente
function eliminar_mencion_de_la_tabla_informacion_general_nueva(thisid){

  id_array = thisid.split("_")
  id = id_array[id_array.length-1]
  $('#p_mencion_informacion_general_'+id).remove();

  
  $('#informacion_general_cantidad_menciones').val( parseInt( $('#informacion_general_cantidad_menciones').val() ) - 1 );
  cant = $('#informacion_general_cantidad_menciones').val();

  for(i = id; i <= cant; i++){
    //tr inicial
    $("#p_mencion_informacion_general_"+(parseInt(i)+1)).attr('id', 'p_mencion_informacion_general_'+i);

    $("#informacion_general_mencion_"+(parseInt(i)+1)).attr('name', 'informacion_general[mencion_'+i+']');
    $("#informacion_general_mencion_"+(parseInt(i)+1)).attr('id', 'informacion_general_mencion_'+i);

    $("#informacion_general_mencion_otra_"+(parseInt(i)+1)).attr('name', 'informacion_general[mencion_otra_'+i+']');
    $("#informacion_general_mencion_otra_"+(parseInt(i)+1)).attr('id', 'informacion_general_mencion_otra_'+i);

    $("#eliminar_mencion_a_informacion_general_button_"+(parseInt(i)+1)).attr('id', 'eliminar_mencion_a_informacion_general_button_'+i);

  }

}

//Formulario para agregar asignatura por docente
$(function() { 
  //Funcion para enviar los datos del formulario de agregacion de asignatura por un docente por AJAX
  $('#formulario_editar_informacion_general').submit(function(){
    $('#editar_informacion_general_submit').attr('disabled','disabled');
    $('#ajax-loader').show();

    codigo = "";
    nombre = "";
    unidades_credito = "";
    tipo = "";
    clasificacion = "";
    requisitos = "";


    if($('#informacion_general_codigo').val()){ codigo = $('#informacion_general_codigo').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#informacion_general_nombre').val()){ nombre = $('#informacion_general_nombre').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#informacion_general_unidades_credito').val()){ unidades_credito = $('#informacion_general_unidades_credito').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#informacion_general_tipo').val()){ tipo = $('#informacion_general_tipo').val().replace(/"/g, '').replace(/'/g, '');}
    if($('#informacion_general_requisitos').val()){ requisitos = $('#informacion_general_requisitos').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}


    if(tipo == "Obligatoria"){
      if($('#informacion_general_clasificacion_obligatoria').val()){ 
        clasificacion = $('#informacion_general_clasificacion_obligatoria').val().replace(/"/g, '').replace(/'/g, '');
      }
    }else{
      if(tipo == "Electiva" || tipo == "Obligatoria optativa"){
        
        clasificacion = []
        cant = $('#informacion_general_cantidad_menciones').val();
        
        for(i = 1; i <= cant; i++){

          if( $('#informacion_general_mencion_'+i).val() ) {

            clasificacion[i-1] = ""
            if( $('#informacion_general_mencion_'+i).val() == "Otra" ) {
              if( $('#informacion_general_mencion_otra_'+i).val() ) {
                clasificacion[i-1] = '{"clasificacion":"'+$('#informacion_general_mencion_otra_'+i).val().replace(/"/g, '').replace(/'/g, '')+'"}';
              }else{
                clasificacion[i-1] = '{"clasificacion":""}';
              }

            }else{
              if( $('#informacion_general_mencion_'+i).val() == "Seleccione" ){
                clasificacion[i-1] = '{"clasificacion":""}';;
              }else{
                clasificacion[i-1] = '{"clasificacion":"'+$('#informacion_general_mencion_'+i).val().replace(/"/g, '').replace(/'/g, '')+'"}';
              }
              
            }

                        
          }else{
            clasificacion[i-1] = '{"clasificacion":""}';
          }

        }

      }
    }


    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { 
        codigo: codigo, nombre: nombre, unidades_credito: unidades_credito,
        clasificacion: clasificacion, tipo: tipo, requisitos: requisitos
      },
      success: function(response) {
        if(response.success == "ok"){
          if(response.url){
            
            url_array = $('#url').attr('href').split("/");
            
            url = "";
            for(i = 0; i < url_array.length-3; i++){
              if(i > 0){ url += "/";}
              url += url_array[i];
            }

            $('#url').attr('href', url+response.url);
          }
          mostrar_exito("Se ha editado la asignatura en el sistema exitosamente.");
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_informacion_general_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
      }
    });
    return false;
  });
});