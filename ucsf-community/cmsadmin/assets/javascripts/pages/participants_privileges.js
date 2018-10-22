$(function() {

    $('.btn-ban-user--trigger').click(function(e) {
        e.preventDefault();

        $('.btn-action').hide();
        $('.btn-confirm').show();
    });

    $('.btn-ban-user--cancel').click(function(e) {
        e.preventDefault();

        $('.btn-action').show();
        $('.btn-confirm').hide();
    });

});