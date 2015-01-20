//Función que actualiza los valores del select de hora fin de horario
function actualizar_hora_fin(id){
  hora = $('#'+id);

  hora_inicio = $('#'+id).val();
  opciones = $('#'+id+' option');
  max = parseInt(opciones[opciones.length-1].value)+5;
  if(max > 21)  max = 21;

  id_array = id.split("_");

  $select = $('#horario_'+id_array[1]+'_hora_fin_'+id_array[id_array.length-2]+'_'+id_array[id_array.length-1]);
  $select.empty();

  for(i=parseInt(hora_inicio);i<max;i++){
    $select.append($("<option></option>").attr("value",i).text(i));
  }

  $select.val( parseInt(hora_inicio)+2 ).prop('selected',true);
}


// Esta función agrega una fila para agregar un horario nuevo al editar
$(function() { 
  return $('.agregar_horario_docente').click(function() {
    array_id = $(this).attr('id').split("_");
    doc = parseInt(array_id[array_id.length-1]);

    $('#docente_cantidad_'+doc).val( parseInt( $('#docente_cantidad_'+doc).val() ) + 1 );
    cant = $('#docente_cantidad_'+doc).val();

    secciones = $('#td_docente_secciones_'+doc).val().split("_");

    if(secciones.length > 0){
      if(secciones.length == 1){
        seccion = '<td style="width: 94px;"><input id="horario_docente_seccion_'+doc+'_'+cant+'" name="horario_docente[';
        seccion += 'seccion_'+doc+'_'+cant+']" type="hidden" value="'+secciones[0]+'">'+secciones[0]+'</td>';
      }else{
        seccion = '<td style="width: 94px;"><select id="horario_docente_seccion_'+doc+'_'+cant+'" name="horario_docente';
        seccion += '[seccion_'+doc+'_'+cant+']"><option value="">Seleccione</option>';
        for(i = 0; i < secciones.length; i++){
          seccion += '<option value="'+secciones[i]+'">'+secciones[i]+'</option>';
        }
        seccion += '</td>';
      }

      
    }else{
      seccion = "<td></td>";
    }

    dia = '<td><select id="horario_docente_dia_'+doc+'_'+cant+'" name="horario_docente[dia_'+doc+'_'+cant+']"><option value="">Seleccione</option>';
    dia +='<option value="Lunes">Lunes</option><option value="Martes">Martes</option><option value="Miércoles">Miércoles</option>';
    dia +='<option value="Jueves">Jueves</option><option value="Viernes">Viernes</option><option value="Sábado">Sábado</option>';
    dia +='<option value="Domingo">Domingo</option></select></td>';

    horas = '<option value="">Seleccione</option>';
    for(i = 7; i < 19; i++){horas += '<option value="'+i+'">'+i+'</option>';}
    hora_inicio = '<td><select id="horario_docente_hora_inicio_'+doc+'_'+cant+'" name="horario_docente[hora_inicio_'+doc+'_'+cant+']" ';
    hora_inicio += 'class="horario_docente_hora_inicio" onchange="actualizar_hora_fin(this.id)">'+horas+'</select></td>';

    hora_fin = '<td><select id="horario_docente_hora_fin_'+doc+'_'+cant+'" name="horario_docente[hora_fin_'+doc+'_'+cant+']"><option value="">Seleccione</option></select></td>';
    tipo ='<td><select class="horario_tipo" id="horario_docente_tipo_'+doc+'_'+cant+'" name="horario_docente[tipo_'+doc+'_'+cant+']"><option value="">Seleccione</option>';
    tipo +='<option value="Teoría">Teoría</option><option value="Práctica">Práctica</option><option value="Laboratorio">Laboratorio</option>';
    tipo +='<option value="Otros">Otros</option></select></td>';
    
    aula = '<td><input type="text" id="horario_docente_aula_'+doc+'_'+cant+'" name="horario_docente[aula_'+doc+'_'+cant+']" placeholder="01" class="horario_aula"></td>'
    eliminar = '<td><a href="#" id="eliminar_horario_docente_'+doc+'_'+cant+'" title="Eliminar horario" onclick="eliminar_horario_docente_tabla(this.id);return false;"><i class="icon-trash"></i></a></td>';


    tds = seccion+dia+hora_inicio+hora_fin+tipo+aula+eliminar;
    tr = '<tr id="tr_horario_docente_'+doc+'_'+cant+'" class="fila_horario">'+tds+'</tr>'
    $('#tbody_horario_docente_'+doc).append(tr);

    url_array = $('#url').attr('href').split("/");

    url = "";
    for(i = 0; i < url_array.length-3; i++){
      if(i > 0){ url += "/";}
      url += url_array[i];
    
    } 

    return $.ajax({
      url: url+'ajax/buscar_datos_horarios',
      success: function(datos) {
        if(datos.tipos){
          tipos = [];
          $.each(datos.tipos, function(i,tipo){ tipos[i] = tipo.tipo; } );
          $( "#horario_docente_tipo_"+doc+"_"+cant ).autocomplete({ source: tipos });

          aulas = [];
          $.each(datos.aulas, function(i,aula){ aulas[i] = aula.aula; } );
          $( "#horario_docente_aula_"+doc+"_"+cant ).autocomplete({ source: aulas });
        }
      }
    });

    if(cant > parseInt(cant)){
      $('#horario_docente_'+doc).show();
    }
  });
});

// Esta función elimina una fila en editar objetivo
function eliminar_horario_docente_tabla(thisid){
  id_array = thisid.split("_")
  doc = id_array[id_array.length-2]
  id = id_array[id_array.length-1]

  $('#tr_horario_docente_'+doc+'_'+id).remove();

  $('#docente_cantidad_'+doc).val( parseInt( $('#docente_cantidad_'+doc).val() ) - 1 );
  cant = $('#docente_cantidad_'+doc).val();

  if(cant == "0"){
    $('#horario_docente_'+doc).hide();
  }

  for(i = id; i <= cant; i++){
    n = parseInt(i) + 1;

    $("#tr_horario_docente_"+doc+"_"+n).attr('id', 'tr_horario_docente_'+doc+"_"+i);

    $("#horario_docente_seccion_"+doc+"_"+n).attr('name', 'horario_docente[seccion_'+doc+"_"+i+"]");
    $("#horario_docente_seccion_"+doc+"_"+n).attr('id', 'horario_docente_seccion_'+doc+"_"+i);

    $("#horario_docente_dia_"+doc+"_"+n).attr('name', 'horario_docente[dia_'+doc+"_"+i+"]");
    $("#horario_docente_dia_"+doc+"_"+n).attr('id', 'horario_docente_dia_'+doc+"_"+i);

    $("#horario_docente_hora_inicio_"+doc+"_"+n).attr('name', 'horario_docente[hora_inicio_'+doc+"_"+i+"]");
    $("#horario_docente_hora_inicio_"+doc+"_"+n).attr('id', 'horario_docente_hora_inicio_'+doc+"_"+i);

    $("#horario_docente_hora_fin_"+doc+"_"+n).attr('name', 'horario_docente[hora_fin_'+doc+"_"+i+"]");
    $("#horario_docente_hora_fin_"+doc+"_"+n).attr('id', 'horario_docente_hora_fin_'+doc+"_"+i);

    $("#horario_docente_tipo_"+doc+"_"+n).attr('name', 'horario_docente[tipo_'+doc+"_"+i+"]");
    $("#horario_docente_tipo_"+doc+"_"+n).attr('id', 'horario_docente_tipo_'+doc+"_"+i);

    $("#horario_docente_aula_"+doc+"_"+n).attr('name', 'horario_docente[aula_'+doc+"_"+i+"]");
    $("#horario_docente_aula_"+doc+"_"+n).attr('id', 'horario_docente_aula_'+doc+"_"+i);

    $("#eliminar_horario_docente_"+doc+"_"+n).attr('id', 'eliminar_horario_docente_'+doc+"_"+i);
  }

  return false;
}




// Esta función agrega una fila para agregar un horario nuevo al editar
$(function() { 
  return $('.agregar_horario_preparador').click(function() {
    array_id = $(this).attr('id').split("_");
    doc = parseInt(array_id[array_id.length-1]);

    $('#preparador_cantidad_'+doc).val( parseInt( $('#preparador_cantidad_'+doc).val() ) + 1 );
    cant = $('#preparador_cantidad_'+doc).val();

    secciones = $('#td_preparador_secciones_'+doc).val().split("_");

    if(secciones.length > 0){
      if(secciones.length == 1){
        seccion = '<td style="width: 94px;"><input id="horario_preparador_seccion_'+doc+'_'+cant+'" name="horario_preparador[';
        seccion += 'seccion_'+doc+'_'+cant+']" type="hidden" value="'+secciones[0]+'">'+secciones[0]+'</td>';
      }else{
        seccion = '<td style="width: 94px;"><select id="horario_preparador_seccion_'+doc+'_'+cant+'" name="horario_preparador';
        seccion += '[seccion_'+doc+'_'+cant+']"><option value="">Seleccione</option>';
        for(i = 0; i < secciones.length; i++){
          seccion += '<option value="'+secciones[i]+'">'+secciones[i]+'</option>';
        }
        seccion += '</td>';
      }
      
    }else{
      seccion = "<td></td>";
    }

    dia = '<td><select id="horario_preparador_dia_'+doc+'_'+cant+'" name="horario_preparador[dia_'+doc+'_'+cant+']"><option value="">Seleccione</option>';
    dia +='<option value="Lunes">Lunes</option><option value="Martes">Martes</option><option value="Miércoles">Miércoles</option>';
    dia +='<option value="Jueves">Jueves</option><option value="Viernes">Viernes</option><option value="Sábado">Sábado</option>';
    dia +='<option value="Domingo">Domingo</option></select></td>';

    horas = '<option value="">Seleccione</option>';
    for(i = 7; i < 19; i++){horas += '<option value="'+i+'">'+i+'</option>';}
    hora_inicio = '<td><select id="horario_preparador_hora_inicio_'+doc+'_'+cant+'" name="horario_preparador[hora_inicio_'+doc+'_'+cant+']" ';
    hora_inicio += 'class="horario_preparador_hora_inicio" onchange="actualizar_hora_fin(this.id)">'+horas+'</select></td>';

    hora_fin = '<td><select id="horario_preparador_hora_fin_'+doc+'_'+cant+'" name="horario_preparador[hora_fin_'+doc+'_'+cant+']"><option value="">Seleccione</option></select></td>';
    tipo ='<td><select class="horario_tipo" id="horario_preparador_tipo_'+doc+'_'+cant+'" name="horario_preparador[tipo_'+doc+'_'+cant+']"><option value="">Seleccione</option>';
    tipo +='<option value="Teoría">Teoría</option><option value="Práctica">Práctica</option><option value="Laboratorio">Laboratorio</option>';
    tipo +='<option value="Otros">Otros</option></select></td>';
    
    aula = '<td><input type="text" id="horario_preparador_aula_'+doc+'_'+cant+'" name="horario_preparador[aula_'+doc+'_'+cant+']" placeholder="01" class="horario_aula"></td>'
    eliminar = '<td><a href="#" id="eliminar_horario_preparador_'+doc+'_'+cant+'" title="Eliminar horario" onclick="eliminar_horario_preparador_tabla(this.id);return false;"><i class="icon-trash"></i></a></td>';

    $('#tbody_horario_preparador_'+doc).append('<tr id="tr_horario_preparador_'+doc+'_'+cant+'" class="fila_horario">'+seccion+dia+hora_inicio+hora_fin+tipo+aula+eliminar+'</tr>');

    return $.ajax({
      url: '/ajax/buscar_datos_horarios',
      success: function(datos) {
        if(datos.tipos){
          tipos = [];
          $.each(datos.tipos, function(i,tipo){ tipos[i] = tipo.tipo; } );
          $( "#horario_preparador_tipo_"+doc+"_"+cant ).autocomplete({ source: tipos });

          aulas = [];
          $.each(datos.aulas, function(i,aula){ aulas[i] = aula.aula; } );
          $( "#horario_preparador_aula_"+doc+"_"+cant ).autocomplete({ source: aulas });
        }
      }
    });

    if(cant > parseInt(cant)){
      $('#horario_preparador_'+doc).show();
    }

    return false;
  });
});

// Esta función elimina una fila en editar objetivo
function eliminar_horario_preparador_tabla(thisid){
  id_array = thisid.split("_")
  doc = id_array[id_array.length-2]
  id = id_array[id_array.length-1]

  $('#tr_horario_preparador_'+doc+'_'+id).remove();

  $('#preparador_cantidad_'+doc).val( parseInt( $('#preparador_cantidad_'+doc).val() ) - 1 );
  cant = $('#preparador_cantidad_'+doc).val();

  if(cant == "0"){
    $('#horario_preparador_'+doc).hide();
  }

  for(i = id; i <= cant; i++){
    n = parseInt(i) + 1;

    $("#tr_horario_preparador_"+doc+"_"+n).attr('id', 'tr_horario_preparador_'+doc+"_"+i);

    $("#horario_preparador_seccion_"+doc+"_"+n).attr('name', 'horario_preparador[seccion_'+doc+"_"+i+"]");
    $("#horario_preparador_seccion_"+doc+"_"+n).attr('id', 'horario_preparador_seccion_'+doc+"_"+i);

    $("#horario_preparador_dia_"+doc+"_"+n).attr('name', 'horario_preparador[dia_'+doc+"_"+i+"]");
    $("#horario_preparador_dia_"+doc+"_"+n).attr('id', 'horario_preparador_dia_'+doc+"_"+i);

    $("#horario_preparador_hora_inicio_"+doc+"_"+n).attr('name', 'horario_preparador[hora_inicio_'+doc+"_"+i+"]");
    $("#horario_preparador_hora_inicio_"+doc+"_"+n).attr('id', 'horario_preparador_hora_inicio_'+doc+"_"+i);

    $("#horario_preparador_hora_fin_"+doc+"_"+n).attr('name', 'horario_preparador[hora_fin_'+doc+"_"+i+"]");
    $("#horario_preparador_hora_fin_"+doc+"_"+n).attr('id', 'horario_preparador_hora_fin_'+doc+"_"+i);

    $("#horario_preparador_tipo_"+doc+"_"+n).attr('name', 'horario_preparador[tipo_'+doc+"_"+i+"]");
    $("#horario_preparador_tipo_"+doc+"_"+n).attr('id', 'horario_preparador_tipo_'+doc+"_"+i);

    $("#horario_preparador_aula_"+doc+"_"+n).attr('name', 'horario_preparador[aula_'+doc+"_"+i+"]");
    $("#horario_preparador_aula_"+doc+"_"+n).attr('id', 'horario_preparador_aula_'+doc+"_"+i);

    $("#eliminar_horario_preparador_"+doc+"_"+n).attr('id', 'eliminar_horario_preparador_'+doc+"_"+i);
  }
  return false;
}



//Esta funcion envia el formulario via AJAX para agilizar la repsuesta con el servidor
$(function() { 
  //Funcion para enviar los datos de los horarios por AJAX
  $('#formulario_editar_horario').submit(function(){
    $('#editar_horario_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    
    horarios = [];
    i = 0;
    $.each($('.fila_horario'), function(){
      array = $(this).attr('id').split("_");

      cargo = array[2];
      doc = array[3];
      id = array[4];

      usuario_id = $('#'+cargo+'_id_'+doc).val();
      //seccion_id = $('#'+cargo+'_seccion_id_'+doc).val();

      dia = "";
      hora_inicio = "";
      hora_fin = "";
      tipo = "";
      aula = "";
      seccion = "";

      if( $('#horario_'+cargo+'_seccion_'+doc+'_'+id).val() ){  seccion = $('#horario_'+cargo+'_seccion_'+doc+'_'+id).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      if( $('#horario_'+cargo+'_dia_'+doc+'_'+id).val() ){  dia = $('#horario_'+cargo+'_dia_'+doc+'_'+id).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      if( $('#horario_'+cargo+'_hora_inicio_'+doc+'_'+id).val() ){  hora_inicio = $('#horario_'+cargo+'_hora_inicio_'+doc+'_'+id).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      if( $('#horario_'+cargo+'_hora_fin_'+doc+'_'+id).val() ){  hora_fin = $('#horario_'+cargo+'_hora_fin_'+doc+'_'+id).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      if( $('#horario_'+cargo+'_tipo_'+doc+'_'+id).val() ){  tipo = $('#horario_'+cargo+'_tipo_'+doc+'_'+id).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
      if( $('#horario_'+cargo+'_aula_'+doc+'_'+id).val() ){  aula = $('#horario_'+cargo+'_aula_'+doc+'_'+id).val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}

      //horarios[i] = '{"cargo":"'+cargo+'","usuario_id":"'+usuario_id+'","seccion_id":"'+seccion_id+'","dia":"'+dia+
      //'","hora_inicio":"'+hora_inicio+'","hora_fin":"'+hora_fin+'", "tipo":"'+tipo+'","aula":"'+aula+'"}';

      horarios[i] = '{"cargo":"'+cargo+'", "usuario_id":"'+usuario_id+'", "seccion":"'+seccion+'", "dia":"'+dia+
      '", "hora_inicio":"'+hora_inicio+'", "hora_fin":"'+hora_fin+'", "tipo":"'+tipo+'", "aula":"'+aula+'"}';

      i++;
    });

    sitio = $(this).attr('action').split("/");
    url = "/"+sitio[1]+"/"+sitio[2]+"/horario/index";

    $.ajax({
       type: "POST",
       data: {horarios: horarios},
       url: $(this).attr('action'),
       success: function(response){
        if(response.success == "ok"){
          window.location = url;
          mostrar_exito("Se guardó el horario exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_horario_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
       }
    });
    return false;
  });

});
