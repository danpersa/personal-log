$( function() {
  
  var idea_list_name = $("#idea_list_name"), 
  edit_idea_list_name = $("#edit_idea_list_name"),
  allFields = $([]).add(idea_list_name).add(edit_idea_list_name);

  $("#new-idea-list-dialog-form").dialog({
    autoOpen: false,
    height: 240,
    width: 400,
    modal: true,
    resizable: false,
    show: "explode",
    hide: "explode",
    buttons: {
      "Create an idea list": function() {
        allFields.removeClass("ui-state-error");
        $('#new_idea_list').submit();
      },
      Cancel: function() {
        $(this).dialog("close");
      }
    },
    close: function() {
      allFields.val("").removeClass("ui-state-error");
      $('.errors').empty();
    }
  });
  
  $("#edit-idea-list-dialog-form").dialog({
    autoOpen: false,
    height: 240,
    width: 400,
    modal: true,
    resizable: false,
    show: "explode",
    hide: "explode",
    buttons: {
      "Edit an idea list": function() {
        allFields.removeClass("ui-state-error");
        $('#edit_idea_list').submit();
      },
      Cancel: function() {
        $(this).dialog("close");
      }
    },
    close: function() {
      allFields.val("").removeClass("ui-state-error");
      $('.errors').html('');
    }
  });

  $("#create-idea-list")
  .button()
  .click(function() {
    $("#new-idea-list-dialog-form").dialog("open");
  });

});

function fillIdeaListForm(id, name) {
  $("#edit_idea_list_id").val(id);
  $("#edit_idea_list_name").val(name);
  $("#edit-idea-list-dialog-form").dialog("open");
}
