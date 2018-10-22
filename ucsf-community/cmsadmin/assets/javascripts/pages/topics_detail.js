$(function() {
	$('.tabbed__options__item').click(function() {
    var tab_id = $(this).attr('data-tab');

    $('.tabbed__options__item').removeClass('tabbed__options__item--current');
    $('.tabbed__item').removeClass('tabbed__item--current');

    $(this).addClass('tabbed__options__item--current');
    $("#" + tab_id).addClass('tabbed__item--current');
  });

    $('.js-close-notification').click(function() {
        $('.notification').hide();
    });

    $('.js-stat-tooltip')
        .click(function(e) {
            e.preventDefault();
        })
        .mouseover(function() {
            $('.js-tooltip-content').show();
        })
        .mouseleave(function() {
            $('.js-tooltip-content').hide();
        });

    var
    $status             = $('.comment_status'),
    $statusOptions      = $('.status-dropdown'),
    $topicStatus        = $('.topic__status__current'),
    $topicStatusOptions = $('.topic__status__dropdown');


    $status.click(function(e) {
        e.preventDefault();

        $(this).parent().find($statusOptions).addClass('status-dropdown--visible');
    });

    $statusOptions.mouseleave(function() {
        $(this).removeClass('status-dropdown--visible');
    });

    $topicStatus.click(function(e) {
        e.preventDefault();

        $(this).parent().find($topicStatusOptions).addClass('topic__status__dropdown--visible');
    });

    $topicStatusOptions.mouseleave(function() {
        $(this).removeClass('topic__status__dropdown--visible');
    });

});