// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
  $('div.hover').hover(
    function() { $(this).addClass('ui-state-hover'); }, 
    function() { $(this).removeClass('ui-state-hover'); }
  );
  
  $('tr.show-close-button').hover(
    function() { $(this).find("div.icon-button").removeClass('invisible'); },
    function() { $(this).find("div.icon-button").addClass('invisible'); }
  );
  
  $("#reminder_reminder_date").datepicker({ dateFormat: 'mm/dd/yy', minDate: new Date()});
  
  $("#idea_idea_list_tokens").tokenInput("/idea_lists.json", {
    crossDomain: false,
    prePopulate: $("#idea_idea_list_tokens").data("pre"),
    preventDuplicates: true,
    hintText: "Type in the name of the list",
    theme: "facebook"
  });
});