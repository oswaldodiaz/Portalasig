/*###############################     GRUPO DOCENTE    ###################################*/

// Esta función agrega una fila para agregar un docente nuevo al editar
function agregar_docente_a_grupo_docente_button() { 
  cedula = $('#input_buscar_docente').val();
  sitio_web_id = $('#sitio_web_id').val();

  url_array = $('#url').attr('href').split("/");
  url = "";
  for(i = 0; i < url_array.length-3; i++){
    if(i > 0){ url += "/";}
    url += url_array[i];
  }

  return $.ajax({
    url: url + '/ajax/buscar_docente_sitio_web_por_cedula?cedula='+cedula+'&sitio_web_id='+sitio_web_id,
    success: function(docentes) {
      if(docentes.length > 0){
        $('#input_buscar_docente').val("");

        $('#tabla_docente').show();
        $('#docente_cantidad').val( parseInt( $('#docente_cantidad').val() ) + 1 );
        cant = $('#docente_cantidad').val();


        docente = docentes[0]

        tr_nueva = '<tr id="tr_docente_'+cant+'" class="fila_docente"></tr>';

        cedula = '<input type="hidden" id="docente_cedula_'+cant+'" name="docente[cedula_'+cant+']" value="'+docente.cedula+'">';

        td_cedula = '<td class="docente_cedula">'+docente.cedula+'</td>';
        td_nombre = '<td class="docente_nombre">'+docente.nombre+'</td>';

        correo = '<td><input type="text" id="docente_correo_'+cant+'" name="docente[correo_'+cant+']" value="'+docente.correo;
        correo += '" placeholder="docente@ejemplo.com" class="docente_correo"/></td>';

        seccion = '<td><input type="text" id="docente_seccion_'+cant+'" name="docente[seccion_'+cant+']" value="'+docente.seccion;
        seccion += '" placeholder="A1" class="docente_seccion"/></td>';

        tipo = '<td><select class="docente_tipo" id="docente_tipo_'+cant+'" name="docente[tipo_'+cant+']">';
        tipo += '<option value="">Seleccione</option><option value="Coordinador" selected="selected">Coordinador</option>';
        tipo += '<option value="Docente">Docente</option><option value="Otro">Otro</option></select></td>';

        eliminar = '<td><a href="#" id="eliminar_docente_'+cant+'" onclick="eliminar_docente_grupo_docente_tabla(this.id);';
        eliminar += 'return false;" title="Eliminar docente"><i class="icon-trash"></i></a></td>';

        $('#tbody_docente').append(tr_nueva);
        $('#tr_docente_'+cant).append(cedula);
        $('#tr_docente_'+cant).append(td_cedula);
        $('#tr_docente_'+cant).append(td_nombre);
        $('#tr_docente_'+cant).append(correo);
        $('#tr_docente_'+cant).append(seccion);
        $('#tr_docente_'+cant).append(tipo);
        $('#tr_docente_'+cant).append(eliminar);

        $('#docente_tipo_'+cant).val(docente.tipo);

        $('#editar_docentes_grupo_docente_submit').show();

        secciones = []
        for(i = 0; i < docente.secciones.length; i++){ secciones[i] = docente.secciones[i].seccion;}
        $( "#docente_seccion_"+cant ).autocomplete({ source: secciones });
        
      }
      else{
        alert("Disculpe, esta cédula no pertenece a ningún docente.");
      }
     
    }
  });
}

// Esta función elimina una fila en editar docente
function eliminar_docente_grupo_docente_tabla(thisid){

  id_array = thisid.split("_")
  id = id_array[id_array.length-1]
  $('#tr_docente_'+id).remove();

  
  $('#docente_cantidad').val( parseInt( $('#docente_cantidad').val() ) - 1 );
  cant = $('#docente_cantidad').val();

  for(i = id; i <= cant; i++){
    //tr inicial
    $("#tr_docente_"+(parseInt(i)+1)).attr('id', 'tr_docente_'+i);

    $("#docente_cedula_"+(parseInt(i)+1)).attr('name', 'docente[cedula_'+i+']');
    $("#docente_cedula_"+(parseInt(i)+1)).attr('id', 'docente_cedula_'+i);

    $("#docente_correo_"+(parseInt(i)+1)).attr('name', 'docente[correo_'+i+']');
    $("#docente_correo_"+(parseInt(i)+1)).attr('id', 'docente_correo_'+i);

    $("#docente_seccion_"+(parseInt(i)+1)).attr('name', 'docente[seccion_'+i+']');
    $("#docente_seccion_"+(parseInt(i)+1)).attr('id', 'docente_seccion_'+i);

    $("#docente_tipo_"+(parseInt(i)+1)).attr('name', 'docente[tipo_'+i+']');
    $("#docente_tipo_"+(parseInt(i)+1)).attr('id', 'docente_tipo_'+i);

    $("#eliminar_docente_"+(parseInt(i)+1)).attr('id', 'eliminar_docente_'+i);

  }

  if(parseInt(cant) == 0){
    $('#tabla_docente').hide();
    $('#editar_docentes_grupo_docente_submit').hide();
  }
}


//Esta funcion envia el formulario via AJAX para agilizar la repsuesta con el servidor
$(function() { 
  //Funcion para enviar un correo al olvidar clave por AJAX
  $('#formulario_editar_docente_grupo_docente').submit(function(){
    $('#editar_docentes_grupo_docente_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    docentes = [];
    cant = $('#docente_cantidad').val();

    for(i = 1; i <= cant; i++){

      cedula = "";
      correo = "";
      seccion = "";
      tipo = "";
      

      if($('#docente_cedula_'+i).val()){  cedula = $('#docente_cedula_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#docente_correo_'+i).val()){  correo = $('#docente_correo_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#docente_seccion_'+i).val()){  seccion = $('#docente_seccion_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#docente_tipo_'+i).val()){  tipo = $('#docente_tipo_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      
      docentes[i-1] = '{"cedula":"'+cedula+'","correo":"'+correo+'","seccion":"'+seccion+'","tipo":"'+tipo+'"}';

    }
    
    $.ajax({
       type: "POST",
       data: {docentes: docentes},
       url: $(this).attr('action'),
       success: function(response){
        if(response.success == "ok"){
          mostrar_exito("Se guardaron los docentes exitosamente.");
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_docentes_grupo_docente_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
       }
    });
    return false;
  });

});


// Esta función agrega una fila para agregar un docente nuevo al editar
function agregar_preparador_a_grupo_docente_button() { 
  cedula = $('#input_buscar_preparador').val();
  sitio_web_id = $('#sitio_web_id').val();

  url_array = $('#url').attr('href').split("/");
  url = "";
  for(i = 0; i < url_array.length-3; i++){
    if(i > 0){ url += "/";}
    url += url_array[i];
  }

  if(es_un_numero(cedula)){

    return $.ajax({
      url: url+'/ajax/buscar_preparador_por_cedula?cedula='+cedula+'&sitio_web_id='+sitio_web_id,
      success: function(preparadores) {
        $('#tabla_preparador').show();

        if(preparadores.length > 0){
          $('#input_buscar_preparador').val("");

          
          $('#preparador_cantidad').val( parseInt( $('#preparador_cantidad').val() ) + 1 );
          cant = $('#preparador_cantidad').val();

          preparador = preparadores[0]


          tr_nueva = '<tr id="tr_preparador_'+cant+'" class="fila_preparador"></tr>';

          cedula = '<input type="hidden" id="preparador_cedula_'+cant+'" name="preparador[cedula_'+cant+']" value="'+preparador.cedula+'">';

          td_cedula = '<td class="preparador_cedula">'+preparador.cedula+'</td>';

          if(preparador.nombre == ""){
            td_nombre = '<td><div class="preparador_nombre"><input type="text" id="preparador_nombre_'+cant+'" name="preparador[nombre_'+cant;
            td_nombre += ']" placeholder="Nombre" class="preparador_nombre_input"/>';

            td_nombre += '<input type="text" id="preparador_apellido_'+cant+'" name="preparador[apellido_'+cant;
            td_nombre += ']" placeholder="Apellido" class="preparador_nombre_input" style="margin-left: 5px;"/></div></td>';

          }else{
            td_nombre = '<td><input type="hidden" id="preparador_nombre_'+cant+'" name="preparador[nombre_'+cant;
            td_nombre += ']" value="'+preparador.nombre.split(" ")[0]+'"/>';

            td_nombre += '<input type="hidden" id="preparador_apellido_'+cant+'" name="preparador[apellido_'+cant+']" value="';
            td_nombre += preparador.nombre.split(" ")[1]+'"/><div class="preparador_nombre">'+preparador.nombre+'</div></td>';
          }



          correo = '<td><input type="text" id="preparador_correo_'+cant+'" name="preparador[correo_'+cant+']" value="'+preparador.correo;
          correo += '" placeholder="preparador@ejemplo.com" class="preparador_correo"/></td>';

          seccion = '<td><input type="text" id="preparador_seccion_'+cant+'" name="preparador[seccion_'+cant+']" value="'+preparador.seccion;
          seccion += '" placeholder="A1" class="preparador_seccion"/></td>';

          tipo = '<td><select class="preparador_tipo" id="preparador_tipo_'+cant+'" name="preparador[tipo_'+cant+']">';
          tipo += '<option value="">Seleccione</option><option value="Auxiliar Docente" selected="selected">Auxiliar Docente</option>';
          tipo += '<option value="Preparador I">Preparador I</option><option value="Preparador II">Preparador II</option><option value="Otro">Otro</option></select></td>';

          eliminar = '<td><a href="#" id="eliminar_preparador_'+cant+'" onclick="eliminar_preparador_grupo_docente_tabla(this.id);';
          eliminar += 'return false;" title="Eliminar preparador"><i class="icon-trash"></i></a></td>';

          $('#tbody_preparador').append(tr_nueva);
          $('#tr_preparador_'+cant).append(cedula);
          $('#tr_preparador_'+cant).append(td_cedula);
          $('#tr_preparador_'+cant).append(td_nombre);
          $('#tr_preparador_'+cant).append(correo);
          $('#tr_preparador_'+cant).append(seccion);
          $('#tr_preparador_'+cant).append(tipo);
          $('#tr_preparador_'+cant).append(eliminar);

          $('#preparador_tipo_'+cant).val(preparador.tipo);

          $('#editar_preparadores_grupo_docente_submit').show();
          

          secciones = []
          for(i = 0; i < preparador.secciones.length; i++){ secciones[i] = preparador.secciones[i].seccion;}
          $( "#preparador_seccion_"+cant ).autocomplete({ source: secciones });

        }
        else{
          alert("Disculpe, esta cédula no pertenece a ningún preparador.");
        }
      }
    });
  }else{
    alert("Disculpe, esta cédula no es correcta.")
  }
}

// Esta función elimina una fila en editar docente
function eliminar_preparador_grupo_docente_tabla(thisid){

  id_array = thisid.split("_");
  id = id_array[id_array.length-1];
  $('#tr_preparador_'+id).remove();

  
  $('#preparador_cantidad').val( parseInt( $('#preparador_cantidad').val() ) - 1 );
  cant = $('#preparador_cantidad').val();

  for(i = id; i <= cant; i++){
    //tr inicial
    $("#tr_preparador_"+(parseInt(i)+1)).attr('id', 'tr_preparador_'+i);

    $("#preparador_cedula_"+(parseInt(i)+1)).attr('name', 'preparador[cedula_'+i+']');
    $("#preparador_cedula_"+(parseInt(i)+1)).attr('id', 'preparador_cedula_'+i);

    $("#preparador_nombre_"+(parseInt(i)+1)).attr('name', 'preparador[nombre_'+i+']');
    $("#preparador_nombre_"+(parseInt(i)+1)).attr('id', 'preparador_nombre_'+i);

    $("#preparador_apellido_"+(parseInt(i)+1)).attr('name', 'preparador[apellido_'+i+']');
    $("#preparador_apellido_"+(parseInt(i)+1)).attr('id', 'preparador_apellido_'+i);

    $("#preparador_correo_"+(parseInt(i)+1)).attr('name', 'preparador[correo_'+i+']');
    $("#preparador_correo_"+(parseInt(i)+1)).attr('id', 'preparador_correo_'+i);

    $("#preparador_seccion_"+(parseInt(i)+1)).attr('name', 'preparador[seccion_'+i+']');
    $("#preparador_seccion_"+(parseInt(i)+1)).attr('id', 'preparador_seccion_'+i);

    $("#preparador_tipo_"+(parseInt(i)+1)).attr('name', 'preparador[tipo_'+i+']');
    $("#preparador_tipo_"+(parseInt(i)+1)).attr('id', 'preparador_tipo_'+i);

    $("#eliminar_preparador_"+(parseInt(i)+1)).attr('id', 'eliminar_preparador_'+i);

  }

  if(parseInt(cant) == 0){
    $('#tabla_preparador').hide();
    $('#editar_preparadores_grupo_docente_submit').hide();
  }
}


//Esta funcion envia el formulario via AJAX para agilizar la repsuesta con el servidor
$(function() { 
  //Funcion para enviar un correo al olvidar clave por AJAX
  $('#formulario_editar_preparadores_grupo_docente').submit(function(){
    $('#editar_preparadores_grupo_docente_submit').attr('disabled','disabled');
    $('#ajax-loader').show();
    preparadores = [];
    cant = $('#preparador_cantidad').val();

    for(i = 1; i <= cant; i++){

      cedula = "";
      nombre = "";
      apellido = "";
      correo = "";
      seccion = "";
      tipo = "";

      if($('#preparador_cedula_'+i).val()){  cedula = $('#preparador_cedula_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#preparador_nombre_'+i).val()){  nombre = $('#preparador_nombre_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#preparador_apellido_'+i).val()){  apellido = $('#preparador_apellido_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#preparador_correo_'+i).val()){  correo = $('#preparador_correo_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#preparador_seccion_'+i).val()){  seccion = $('#preparador_seccion_'+i).val().replace(/"/g, '').replace(/'/g, '');}
      if($('#preparador_tipo_'+i).val()){  tipo = $('#preparador_tipo_'+i).val().replace(/"/g, '').replace(/'/g, '');}

      preparadores[i-1] = '{"cedula":"'+cedula+'","nombre":"'+nombre+'","apellido":"'+apellido+'",';
      preparadores[i-1] += '"correo":"'+correo+'","seccion":"'+seccion+'","tipo":"'+tipo+'"}';

    }
    
    $.ajax({
       type: "POST",
       data: {preparadores: preparadores},
       url: $(this).attr('action'),
       success: function(response){
        if(response.success == "ok"){
          mostrar_exito("Se guardaron los preparadores exitosamente.");
        }else{
          mostrar_error(response.errores);
        }
        $('#editar_preparadores_grupo_docente_submit').removeAttr('disabled');
        $('#ajax-loader').hide();
       }
    });
    return false;
  });

});
