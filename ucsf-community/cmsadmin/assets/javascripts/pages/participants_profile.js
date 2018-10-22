$(function() {
    $('.tabbed__options__item').click(function(e) {
        e.preventDefault();
        var tab_id = $(this).attr('data-tab');

        $('.tabbed__options__item').removeClass('tabbed__options__item--current');
        $('.tabbed__item').removeClass('tabbed__item--current');

        $(this).addClass('tabbed__options__item--current');
        $("#" + tab_id).addClass('tabbed__item--current');
    });


    $('.js-close-notification').click(function() {
        $('.notification').hide();
    });
});