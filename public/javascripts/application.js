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
    width: 100,
    menuWidth: 100
  });
  

  $("#reminder_reminder_date").datepicker({
    dateFormat: 'mm/dd/yy',
    minDate: new Date()
  });
});

function addNotification(message, styleClass) {
  $("#main-section").prepend(
    '<div class="flash ' + styleClass + '">' + message + '</div>'
  );
}

function addNotificationNotice(message) {
  addNotification(message, "notice");
}

function addNotificationSuccess(message) {
  addNotification(message, "success");
}

function updateErrors(form, field, prefix, t) {
  form.find('#' + prefix + field).addClass( "ui-state-error" );
  form.find('#' + prefix + field + '_errors')
    .html(t)
    .addClass( "ui-state-highlight" );
  setTimeout(function() {
    form.find('#' + prefix + field + '_errors').removeClass( "ui-state-highlight", 500 );
  }, 250 );
}


