$( function() {
  
  var idea_list_name = $("#idea_list_name"),
  allFields = $([]).add(idea_list_name);

  $("#dialog-form").dialog({
    autoOpen: false,
    height: 230,
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

  $("#create-idea-list")
  .button()
  .click(function() {
    $("#dialog-form").dialog("open");
  });
  
  // $(".edit-idea-list")
  // .button()
  // .click(function() {
    // $("#idea_list_name").
    // $("#dialog-form").dialog("open");
  // });
  
});

function fillIdeaListForm(id, name) {
  $("#idea_list_id").val(id);
  $("#idea_list_name").val(name);
  $("#dialog-form").dialog("open");
}
