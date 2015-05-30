$(function() {
    $('.tasks article h1 div').click(function(event) {
        $(this).toggleClass('complete');
        event.stopImmediatePropagation();
    });

    $('.tasks article h1').click(function(event) {
        $(this).parent().toggleClass('closed');
    });
});
