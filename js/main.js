$(function() {
    $('section article > div > div').each(function(i, el) {
        var el = $(el);
        var height = el.height() + 30;
        if (!$(this).parent().parent().hasClass('force-open'))
            el.parent().css({height: height + 'px'});
    });

    $('.tasks article h1 div').click(function(event) {
        $(this).toggleClass('complete');
        event.stopImmediatePropagation();
    });

    $('.tasks article h1').click(function(event) {
        if (!$(this).hasClass('force-open'))
            $(this).parent().toggleClass('closed');
    });

    $('.options.hotels a').click(function(event) {
        event.preventDefault();
        $('.hotel-name').text($(this).data('name'));
        $('.drive-time').text('50 mins');
        $('.options.hotels > div').addClass('lighter')
        $(this).parent().removeClass('lighter');
    });

    $('#open-acts').click(function(event) {
        event.preventDefault();
        $('#actual-acts').removeClass('closed');
    });

    var muay = sessionStorage.getItem('muay');
    if (muay == 'false' || muay == null) {
        sessionStorage.setItem('muay', true);
    } else {
        $('#actual-acts').addClass('muay');
        sessionStorage.setItem('muay', false);
    }

    $('.options.activities a').click(function(event) {
        event.preventDefault();
        $('.options.activities > div').addClass('lighter')
        $(this).parent().removeClass('lighter');
    });
});
