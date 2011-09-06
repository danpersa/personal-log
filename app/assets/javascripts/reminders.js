$( function() {

  $(".popup").CreateBubblePopup();
  

  $('.popup').mouseover(function(){
      
      //show the bubble popup with new options
      $(this).ShowBubblePopup({ innerHtml: $(this).attr("alt"),
              themeName:  'azure',
              themePath:  'assets'                 
              });
    });
});