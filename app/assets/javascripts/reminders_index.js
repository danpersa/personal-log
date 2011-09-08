$( function() {
    $(".popup").CreateBubblePopup();

    $('.popup').mouseover(function(){
        //show the bubble popup with new options
        $(this).ShowBubblePopup({
            selectable: true,
            innerHtml: $(this).attr("alt"),
            innerHtmlStyle: {
                color:'#OOOOOO', 
                background: '#FFFFFF',
                'text-align':'center'
            },
            themeName:  'azure',
            themePath:  'assets'                 
        });
    });
});