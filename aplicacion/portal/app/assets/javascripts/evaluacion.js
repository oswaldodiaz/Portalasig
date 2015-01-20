/*###############################     Evaluacion   ###################################*/

$(function() {
  $.each($('.evaluacion_fecha'), function(){
    $(this).datepicker({
      dateformat: 'dd/mm/yy',
      changeMonth: true,
      changeYear: true,
      yearRange: "-1:+1"
    });

    $(this).datepicker($.datepicker.regional['es']);
  });
});

// Esta función agrega una fila para agregar una evaluacion nueva
$(function() { 
  $('#agregar_evaluacion_button').click(function() {
    $('#tabla_evaluacion').show();
    $('#eval_can').val( parseInt( $('#eval_can').val() ) + 1 );
    cant = $('#eval_can').val();
    
    fecha = new Date();
    dia = fecha.getDate();
    if(dia < 10){ dia = "0"+dia;}
    mes = fecha.getMonth();
    if(mes < 10){ mes = "0"+mes;}
    hoy = dia+"/"+mes+"/"+fecha.getFullYear();

    id = '<input type="hidden" id="evaluacion_id_'+cant+'" name="evaluacion[id_'+cant+']" value="-1">';
    nombre = '<td><input type="text" id="evaluacion_nombre_'+cant+'" name="evaluacion[nombre_'+cant+']" placeholder="Parcial 1" class="evaluacion_nombre"></td>';
    
    tipo = '<td><select class="evaluacion_tipo" id="evaluacion_tipo_'+cant+'" name="evaluacion[tipo_'+cant+']"><option value="">Seleccione</option>';
    tipo += '<option value="Teoría">Teoría</option><option value="Práctica">Práctica</option>';
    tipo += '<option value="Laboratorio">Laboratorio</option><option value="Otro">Otro</option></select></td>';

    valor = '<td><input type="text" id="evaluacion_valor_'+cant+'" name="evaluacion[valor_'+cant+']" placeholder="30" class="evaluacion_valor"></td>';
    fecha_inicio = '<td><input type="text" id="evaluacion_fecha_inicio_'+cant+'" name="evaluacion[fecha_inicio_'+cant+']" placeholder="'+hoy+'" class="evaluacion_fecha" onchange="cambiar_fecha_fin(this.id)"></td>';
    fecha_fin = '<td><input type="text" id="evaluacion_fecha_fin_'+cant+'" name="evaluacion[fecha_fin_'+cant+']" placeholder="'+hoy+'" class="evaluacion_fecha"></td>';
    eliminar = '<td><a href="#" id="eliminar_evaluacion_'+cant+'" title="Eliminar evaluación" onclick="eliminar_evaluacion_tabla(this.id);return false;"><i class="icon-trash"></i></a></td>';
   
    tr = '<tr id="tr_evaluacion_'+cant+'" class="fila_evaluacion">'+id+nombre+tipo+valor+fecha_inicio+fecha_fin+eliminar+'</tr>';
    $('#tbody_evaluacion').append(tr);

    $('#evaluacion_fecha_inicio_'+cant).datepicker({
      dateformat: 'dd/mm/yy',
      changeMonth: true,
      changeYear: true,
      yearRange: "-1:+1"
    });

    $('#evaluacion_fecha_inicio_'+cant).datepicker($.datepicker.regional['es']);

    $('#evaluacion_fecha_fin_'+cant).datepicker({
      dateformat: 'dd/mm/yy',
      changeMonth: true,
      changeYear: true,
      yearRange: "-1:+1"
    });

    $('#evaluacion_fecha_fin_'+cant).datepicker($.datepicker.regional['es']);

  });
});


function eliminar_evaluacion_tabla(thisid){
  id_array = thisid.split("_")
  id = id_array[id_array.length-1]
  $('#tr_evaluacion_'+id).remove();

  $('#eval_can').val( parseInt( $('#eval_can').val() ) - 1 );
  cant = $('#eval_can').val();

  for(i = id; i <= cant; i++){
    $("#tr_evaluacion_"+(parseInt(i)+1)).attr('id', "tr_evaluacion_"+i);
    
    $("#evaluacion_nombre_"+(parseInt(i)+1)).attr('name', 'evaluacion[nombre_'+i+"]");
    $("#evaluacion_nombre_"+(parseInt(i)+1)).attr('id', 'evaluacion_nombre_'+i);

    $("#evaluacion_tipo_"+(parseInt(i)+1)).attr('name', 'evaluacion[tipo_'+i+"]");
    $("#evaluacion_tipo_"+(parseInt(i)+1)).attr('id', 'evaluacion_tipo_'+i);

    $("#evaluacion_valor_"+(parseInt(i)+1)).attr('name', 'evaluacion[valor_'+i+"]");
    $("#evaluacion_valor_"+(parseInt(i)+1)).attr('id', 'evaluacion_valor_'+i);

    $("#evaluacion_fecha_inicio_"+(parseInt(i)+1)).attr('name', 'evaluacion[fecha_inicio_'+i+"]");
    $("#evaluacion_fecha_inicio_"+(parseInt(i)+1)).attr('id', 'evaluacion_fecha_inicio_'+i);

    $("#evaluacion_fecha_fin_"+(parseInt(i)+1)).attr('name', 'evaluacion[fecha_fin_'+i+"]");
    $("#evaluacion_fecha_fin_"+(parseInt(i)+1)).attr('id', 'evaluacion_fecha_fin_'+i);

    $("#eliminar_evaluacion_"+(parseInt(i)+1)).attr('id', 'eliminar_evaluacion_'+i);
  }

  if(parseInt(cant) == 0){$('#tabla_evaluacion').hide();}
}

function  cambiar_fecha_fin(thisid){
  id = thisid.split("_");
  $('#evaluacion_fecha_fin_'+id[3]).val($('#'+thisid).val());
}


//Esta funcion envia el formulario via AJAX para agilizar la repsuesta con el servidor
$(function() { 
  //Funcion para enviar los datos de las evaluaciones por AJAX
  $('#formulario_editar_evaluaciones').submit(function(){
    $('#editar_evaluacion_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    evaluaciones = []; 
    i = 0;

    cant = $('#eval_can').val();
    for(i = 1; i <= cant; i++){
      if ($('#evaluacion_id_'+i).val()){ ev_id = $('#evaluacion_id_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      else{  ev_id = "";}
      
      if ($('#evaluacion_nombre_'+i).val()){ nombre = $('#evaluacion_nombre_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      else{  nombre = "";}
      
      if ($('#evaluacion_tipo_'+i).val()){ tipo = $('#evaluacion_tipo_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      else{  tipo = "";}
      
      if ($('#evaluacion_valor_'+i).val()){ valor = $('#evaluacion_valor_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      else{  valor = "";}
      
      if ($('#evaluacion_fecha_inicio_'+i).val()){ fecha_inicio = $('#evaluacion_fecha_inicio_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      else{  fecha_inicio = "";}
      
      if ($('#evaluacion_fecha_fin_'+i).val()){ fecha_fin = $('#evaluacion_fecha_fin_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      else{  fecha_fin = "";}
      
      evaluaciones[i-1] = '{"id":"'+ev_id+'","nombre":"'+nombre+'","tipo":"'+tipo+'","valor":"'+valor;
      evaluaciones[i-1] += '","fecha_inicio":"'+fecha_inicio+'","fecha_fin":"'+fecha_fin+'"}';
    }

    $.ajax({
       type: "POST",
       data: {evaluaciones: evaluaciones},
       url: $(this).attr('action'),
       success: function(response){
        if(response.success == "ok"){
          mostrar_exito("Se guardaron las evaluaciones exitosamente.")
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_evaluacion_submit').removeAttr('disabled');
        $('#ajax-loader').hide();

       }
    });

    return false;
  });

});

