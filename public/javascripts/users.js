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
});