$(function() {
  $(".pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
});

function reRenderIdeas() {
  $("#ideas").html("<%= escape_javascript(render("idea_list_table")) %>");
  initHoverIcons();
};
