var tooltip,
  eventos = [],
  ids = [],
  descripciones = [],
  url = "";


function agregar_calendario() {
  nombre_url = $('#sitio_web_nombre_url').val();
  periodo = $('#sitio_web_periodo').val();
  es_del_grupo_docente = $('#es_del_grupo_docente').val();
  sitio_web_id = $('#sitio_web_id').val();

  editable = es_del_grupo_docente

  url_array = $('#url2').attr('href').split("/");

  url2 = "";
  for(i = 0; i < url_array.length-3; i++){
    if(i > 0){ url2 += "/";}
    url2 += url_array[i];
  
  } 

  url = url2+"/"+nombre_url+"/"+periodo+"/planificacion/eliminar_evento/";


  tooltip = $('<div/>').qtip({
    id: 'calendar',
    prerender: true,
    content: {
      text: ' ',
      title: {
        button: true
      }
    },
    
    position: {
      my: 'bottom center',
      at: 'top center',
      target: 'mouse',
      adjust: {
        mouse: false,
        scroll: false
      }
    },
    
    show: false,
    hide: {
      event: 'click'
    },

    style: {
        classes: 'qtip-shadow qtip-light qtip-rounded qtip-blue',
        width: '200px'
    }

  }).qtip('api');

  jQuery.getJSON(url2+"/ajax/eventos/"+sitio_web_id,function(data){

    $.each(data, function(i,evento){
      titulo = evento.titulo;
      inicio = (evento.fecha_inicio.split("T")[0]).toString();
      fin = (evento.fecha_fin.split("T")[0]).toString();

      ids[i] = evento.id;
      descripciones[i] = evento.descripcion;

      f = inicio.split("-");
      f1 = new Date(f[0],f[1]-1,f[2],0,0,0);

      f = fin.split("-");
      f2 = new Date(f[0],f[1]-1,f[2],0,0,0);

      f3 = new Date();
      f3.setHours(0,0,0,0);

      if(f2 < f3){
        color = '#FF0000';
      }else{
        if(f3 < f1){
          color = '#00FF00';
        }else{
          color = '#0000FF';
        }
      }

      eventos[i] = {
        id: i,
        title: titulo,
        start: inicio,
        end: fin,
        color: color
      };
      
      i++;
    })

    $('#calendar').fullCalendar({
      editable: true,

      header: {
        left: 'month,basicWeek,basicDay',
        center: 'title',
        right: 'prev,next today'
      },

      theme: true,

      buttonText: {
        prev: '&lt;',
        next: '&gt;',
        today: 'hoy',
        day: 'Día',
        week: 'Semana',
        month: 'Mes'
      },

      columnFormat: {
        month: 'dddd',    // Mon
        week: 'dddd d', // Mon 9/7
        day: 'dddd d MMMM'  // Monday 9/7
      },

      titleFormat: {
        month: 'MMMM yyyy',                             // September 2009
        week: "MMMM d  [ yyyy]{ '&#8212;'[ MMMM] d yyyy}", // Sep 7 - 13 2009
        day: 'dddd, MMMM d, yyyy'                  // Tuesday, Sep 8, 2009
      },

      monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio',
                  'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],

      monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul',
                    'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],

      dayNames: ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"], 

      dayNamesShort: ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"],

      weekends: false,

      weekMode: 'liquid',


      eventClick: function(data, event, view) {
        $('#event_id').val(ids[data.id]);
        $('#event_titulo').val(data.title);
        $('#event_descripcion').val(descripciones[data.id]);
                  
        dia = data.start.getDate();
        mes = data.start.getMonth()+1;          
        if(parseInt(dia) < 10) dia = "0"+dia;
        if(parseInt(mes) < 10) mes = "0"+mes;
        fecha = dia + "/" + mes + "/" + data.start.getFullYear();
        $('#event_fecha_inicio').val(fecha);

        if(data.end){
          dia = data.end.getDate();
          mes = data.end.getMonth()+1;          
          if(parseInt(dia) < 10) dia = "0"+dia;
          if(parseInt(mes) < 10) mes = "0"+mes;
          fecha = dia + "/" + mes + "/" + data.end.getFullYear();
        }
        $('#event_fecha_fin').val(fecha);

        var content = '<h3>'+data.title+'</h3><hr style="margin: 0px 0px 5px 0px;"><p>'+descripciones[data.id]+'</p>';
        
        if(editable == "true"){
          content += '<br><p><a href="#Modal_evento_existente" role="button" data-toggle="modal"';
          content += ' id="llamador_Modal_evento_nuevo" onclick="tooltip.hide()"><i class="icon-pencil"></i></a><a href="#" onclick=';
          content += '"if(confirm(' + "'¿está seguro que desea eliminar este evento?'" + ')){eliminar_este_evento('+data.id+');} return false;" style="float:right"><i class="icon-trash"></i></a></p>';
        }

        tooltip.set({
          'content.text': content
        })
        .reposition(event).show(event);

        
        $('#error_evento_nuevo').hide();
        $('#eliminar_evento_button').attr('href', url + $('#event_id').val() );
      },
      
      dayClick: function(date, allDay, jsEvent, view) {
        tooltip.hide();

        dia = date.getDate();
        mes = date.getMonth()+1;
        
        if(parseInt(dia) < 10) dia = "0"+dia;
        if(parseInt(mes) < 10) mes = "0"+mes;
        
        fecha = dia + "/" + mes + "/" + date.getFullYear();
        
        $('#fecha_evento').empty().append(fecha);
        $('#evento_fecha_inicio').val(fecha);
        $('#evento_fecha_fin').val(fecha);
        $('#error_evento_nuevo').hide();
        $('#llamador_Modal_evento_nuevo').click();
      },
      
      eventResizeStart: function() { tooltip.hide() },
      
      eventDragStart: function() { tooltip.hide() },

      eventDrop: function( evento, jsEvent, ui, view ) {
        id = ids[evento.id];
        dia = evento.start.getDate();
        mes = evento.start.getMonth()+1;          
        if(parseInt(dia) < 10) dia = "0"+dia;
        if(parseInt(mes) < 10) mes = "0"+mes;
        fecha_inicio = dia + "/" + mes + "/" + evento.start.getFullYear();

        fecha_fin = fecha_inicio;
        if(data.end){
          dia = data.end.getDate();
          mes = data.end.getMonth()+1;          
          if(parseInt(dia) < 10) dia = "0"+dia;
          if(parseInt(mes) < 10) mes = "0"+mes;
          fecha_fin = dia + "/" + mes + "/" + data.end.getFullYear();
        }

        $.ajax({
          url: url2+"/"+nombre_url+'/'+periodo+'/planificacion/modificar_fecha_evento?id='+id+'&fecha_inicio='+fecha_inicio+'&fecha_fin='+fecha_fin,
          success: function(response) {
            if(response.success == "ok"){
              mostrar_exito("Se actualizó el evento satisfactoriamente");
            }
          }
        });
      },
      
      viewDisplay: function() { tooltip.hide() },
      
      events: eventos
    });

  });

  $('#Modal_evento_existente').on('show', function() {
    $('.qtip').qtip('hide');
    $("#event_titulo").focus();      
  });

}


$(function() { 
  //Funcion para enviar un correo al olvidar clave por AJAX
  $('#formulario_evento_nuevo').submit(function(){
    $('#crear_evento_nuevo_button').attr('disabled','disabled');
    $( "#ajax-loader" ).show();

    fecha_inicio = "";
    fecha_fin = "";
    titulo = "";
    descripcion = "";

    if( $('#evento_fecha_inicio').val() ){  fecha_inicio = $('#evento_fecha_inicio').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if( $('#evento_fecha_fin').val() ){  fecha_fin = $('#evento_fecha_fin').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if( $('#evento_titulo').val() ){  titulo = $('#evento_titulo').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if( $('#evento_descripcion').val() ){  descripcion = $('#evento_descripcion').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { fecha_inicio: fecha_inicio, fecha_fin: fecha_fin, titulo: titulo, descripcion: descripcion },
      success: function(response) {
        if(response.success == "ok"){
          $('#cerrar_modal_evento_nuevo').click();
          mostrar_exito("Se ha agregado el evento a la planificación. Si no aparece en el calendario refresque la página.");

          i = eventos.length;
          ids[i] = response.id;
          descripciones[i] = descripcion;

          fecha_array = fecha_inicio.split("/")
          inicio = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

          fecha_array = fecha_fin.split("/")
          fin = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

          f = inicio.split("-");
          f1 = new Date(f[0],f[1]-1,f[2],0,0,0);

          f = fin.split("-");
          f2 = new Date(f[0],f[1]-1,f[2],0,0,0);

          f3 = new Date();
          f3.setHours(0,0,0,0);

          if(f2 < f3){
            color = '#FF0000';
          }else{
            if(f3 < f1){
              color = '#00FF00';
            }else{
              color = '#0000FF';
            }
          }

          eventos[i] = {
            id: i,
            title: titulo,
            start: inicio,
            end: fin,
            color: color
          };

          $('#calendar').fullCalendar( 'addEventSource', eventos[i] );
          $('#calendar').fullCalendar( 'refetchEvents' );

          $('#evento_fecha_inicio').val("");
          $('#evento_fecha_fin').val("");
          $('#evento_titulo').val("");
          $('#evento_descripcion').val("");
          $('#error_evento_nuevo').hide();
        }else{
          errores = response.errores;
          $('#error_evento_nuevo').show();
          $("#error_evento_nuevo").attr('class', 'alert alert-error');
          $('#flash_evento_nuevo').empty();
          if(errores.length > 1){
            $('#flash_evento_nuevo').append("<ol>Se cometieron los siguientes errores:");
            $.each(errores, function(i,error){
              $('#flash_evento_nuevo').append("<li>"+error.error+"</li>");
            });
            $('#flash_evento_nuevo').append("</ol>");
          }else{
            $('#flash_evento_nuevo').text(errores[0].error);
          }
        }
        $('#crear_evento_nuevo_button').removeAttr('disabled');
        $( "#ajax-loader" ).hide();
      }
    });
    return false;
  });

});

$(function() { 
  //Funcion para enviar un correo al olvidar clave por AJAX
  $('#formulario_editar_evento').submit(function(){
    $('#editar_evento_button').attr('disabled','disabled');
    $( "#ajax-loader" ).show();

    id = "";
    fecha_inicio = "";
    fecha_fin = "";
    titulo = "";
    descripcion = "";

    if( $('#event_id').val() ){  id = $('#event_id').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if( $('#event_fecha_inicio').val() ){  fecha_inicio = $('#event_fecha_inicio').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if( $('#event_fecha_fin').val() ){  fecha_fin = $('#event_fecha_fin').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if( $('#event_titulo').val() ){  titulo = $('#event_titulo').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}
    if( $('#event_descripcion').val() ){  descripcion = $('#event_descripcion').val().replace(/"/g, '').replace(/'/g, '').replace(/\n/g, '');}

    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: { id: id, fecha_inicio: fecha_inicio, fecha_fin: fecha_fin, titulo: titulo, descripcion: descripcion },
      success: function(response) {
        if(response.success == "ok"){
          $('#cerrar_modal_editar_evento').click();
          mostrar_exito("Se ha editado el evento de la planificación exitosamente.");

          i = 0;
          while(ids[i] != response.id && i < ids.length) i++;

          descripciones[i] = descripcion;
          fecha_array = fecha_inicio.split("/")
          inicio = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

          fecha_array = fecha_fin.split("/")
          fin = fecha_array[2]+"-"+fecha_array[1]+"-"+fecha_array[0]

          f = inicio.split("-");
          f1 = new Date(f[0],f[1]-1,f[2],0,0,0);

          f = fin.split("-");
          f2 = new Date(f[0],f[1]-1,f[2],0,0,0);

          f3 = new Date();
          f3.setHours(0,0,0,0);

          if(f2 < f3){
            color = '#FF0000';
          }else{
            if(f3 < f1){
              color = '#00FF00';
            }else{
              color = '#0000FF';
            }
          }

          eventos[i].title = titulo;
          eventos[i].start = fecha_inicio;
          eventos[i].end = fecha_fin;
          eventos[i].color = color;

          evento_a_modificar = $('#calendar').fullCalendar( 'clientEvents', [i] )[0];

          if (evento_a_modificar != null)
          {
            evento_a_modificar.title = titulo;
            evento_a_modificar.start = inicio;
            evento_a_modificar.end = fin;
            evento_a_modificar.color = color;

            $('#calendar').fullCalendar( 'updateEvent', evento_a_modificar );

            $('#calendar').fullCalendar( 'refetchEvents' );
          }

          $('#event_fecha_inicio').val("");
          $('#event_fecha_fin').val("");
          $('#event_titulo').val("");
          $('#event_descripcion').val("");
          $('#error_editar_evento').hide();

        }else{
          errores = response.errores;
          $('#error_editar_evento').show();
          $("#error_editar_evento").attr('class', 'alert alert-error');
          $('#flash_editar_evento').empty();
          if(errores.length > 1){
            $('#flash_editar_evento').append("<ol>Se cometieron los siguientes errores:");
            $.each(errores, function(i,error){
              $('#flash_editar_evento').append("<li>"+error.error+"</li>");
            });
            $('#flash_editar_evento').append("</ol>");
          }else{
            $('#flash_editar_evento').text(errores[0].error);
          }
        }

        $('#editar_evento_button').removeAttr('disabled');
        $( "#ajax-loader" ).hide();
      }
    });
    return false;
  });

});

function eliminar_este_evento(id){
  tooltip.hide();
  $.ajax({
    type: "POST",
    url: url,
    data: { id: ids[id] },
    success: function(response) {
      if(response.success == "ok"){
        mostrar_exito("Se ha eliminado el evento de la planificación exitosamente.");

        $('#calendar').fullCalendar( 'removeEvents', id );
        $('#calendar').fullCalendar( 'refresh' );
      }else{
        mostrar_error(response.errores);
      }
    }
  });
}