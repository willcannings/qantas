$(function() {
    $('section article > div > div').each(function(i, el) {
        var el = $(el);
        var height = el.height() + 30;
        el.parent().css({height: height + 'px'});
    });

    $('.tasks article h1 div').click(function(event) {
        $(this).toggleClass('complete');
        event.stopImmediatePropagation();
    });

    $('.tasks article h1').click(function(event) {
        $(this).parent().toggleClass('closed');
    });
});
