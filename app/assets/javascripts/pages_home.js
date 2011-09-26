$( function() {

  $("#new_reminder_post").button();


  initHoverIcons();

  $("#new_reminder_privacy_id").selectmenu({
    transferClasses: true,
    style: "dropdown",
    width: 100,
    menuWidth: 100
  });


  $("#new_reminder_reminder_date").datepicker({
    dateFormat: 'dd/mm/yy',
    minDate: new Date()
  });
});