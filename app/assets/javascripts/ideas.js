$( function() {
  $("#idea_idea_list_tokens").tokenInput("/idea-lists.json", {
    crossDomain: false,
    prePopulate: $("#idea_idea_list_tokens").data("pre"),
    preventDuplicates: true,
    hintText: "Type in the name of the list",
    theme: "facebook"
  });
});