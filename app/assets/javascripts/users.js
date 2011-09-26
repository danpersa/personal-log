$( function() {

// the ajax pagination disables the drag and drop
// TODO find out why!
//  initAjaxPagination();

  $("button, input:submit").button();

  initHoverIcons();
  
  $("#ideas tr").draggable({
      appendTo: "body",
      cursorAt: { cursor: "move", bottom: 0, left: 56 },
      helper: function(event) {
        return $( "<div class='ui-widget-header'>Drag me to an idea list</div>" );
      }
  });
  
  $(".idea_list_li").droppable({
      activeClass: "ui-state-default",
      hoverClass: "ui-state-hover",
      accept: ":not(.ui-sortable-helper)",
      drop: function(event, ui) {
        
        var ideaId = ui.draggable.attr("id").substring("idea".length + 1)
        var ideaListId = $(this).attr("id").substring("idea_list".length + 1)
        
        /* $(this).find(".placeholder").remove();
        $("<li></li>").text(ideaId + "-" + ideaListId).appendTo(this); */
        
        $.ajax({
                type: 'post', 
                data: 'idea_id=' + ideaId, 
                dataType: 'script', 
                complete: function(request) {
                    $('#idea_list_' + ideaListId).effect('highlight');
                  },
                url: '/idea-lists/' + ideaListId + '/add-idea'});
      }
  });
});
