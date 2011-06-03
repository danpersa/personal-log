// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$( function() {

  $("button, input:submit").button();

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
  
  $("#reminder_privacy_id").selectmenu({
    transferClasses: true,
    style: "dropdown",
    width: 100
  });
  

  $("#reminder_reminder_date").datepicker({
    dateFormat: 'mm/dd/yy',
    minDate: new Date()
  });
});