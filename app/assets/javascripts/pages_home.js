$( function() {


  initHoverIcons();

  $("#new_reminder_reminder_date").datepicker({
    dateFormat: 'dd/mm/yy',
    minDate: new Date()
  });
});