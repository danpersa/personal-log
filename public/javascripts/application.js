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
  
  $("#micropost_reminder_date").datepicker({ dateFormat: 'dd/mm/yy', minDate: new Date()});
});