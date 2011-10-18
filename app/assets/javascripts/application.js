//= require jquery
//= require jquery_ujs
//= require plugins
//= require jquery-ui-1-8-11-custom-min
//= require jquery-tokeninput
//= require jquery-tipTip
//= require_self
//-----= xxrequire_tree .

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$( function() {

  //$("button, input:submit").button();
  
  $('#topbar').dropdown();
  
//  $(".alert-message").alert();
//  $(".alert-message").alert('close');
});

function addNotification(message, styleClass) {
  $("#main-section").prepend(
    '<div class="flash ' + styleClass + '">' + message + '</div>'
  );
  
  setTimeout(function() {
    $(".flash:first").fadeOut();
  }, 3000);
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

function initHoverIcons() {
  $('div.hover').hover( function() {
    $(this).addClass('ui-state-hover');
  }, function() {
    $(this).removeClass('ui-state-hover');
  }
  );

  $('div.show-close-button').hover( function() {
    $(this).find("div.icon-button").removeClass('invisible');
  }, function() {
    $(this).find("div.icon-button").addClass('invisible');
  }
  );
}

function initAjaxPagination() {
  $(".pagination a").live("click", function() {
    $.getScript(this.href);
    history.pushState(null, document.title, this.href);
    return false;
  });
  
  $(window).bind("popstate", function() {
    $.getScript(location.href);
  });
}
