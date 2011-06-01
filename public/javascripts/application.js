// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$( function() {

  $('div.hover').hover( function() {
    $(this).addClass('ui-state-hover');
  }, function() {
    $(this).removeClass('ui-state-hover');
  }
  );

  $('tr.show-close-button').hover( function() {
    $(this).find("div.icon-button").removeClass('invisible');
  }, function() {
    $(this).find("div.icon-button").addClass('invisible');
  }
  );

  $("#reminder_reminder_date").datepicker({
    dateFormat: 'mm/dd/yy',
    minDate: new Date()
  });

  $("#idea_idea_list_tokens").tokenInput("/idea-lists.json", {
    crossDomain: false,
    prePopulate: $("#idea_idea_list_tokens").data("pre"),
    preventDuplicates: true,
    hintText: "Type in the name of the list",
    theme: "facebook"
  });

  $( "#dialog-form" ).dialog({
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
      el.find('.errors').empty();
    }
  });
  
  var idea_list_name = $("#idea_list_name"),
  allFields = $([]).add(idea_list_name);

  $("#create-idea-list")
  .button()
  .click(function() {
    $("#dialog-form").dialog("open");
  });
});