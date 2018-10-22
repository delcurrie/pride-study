$(function() {
    
    var fromOrTo = null;

    $("input.search").keypress(function(event) {
        if (event.which == 13) {
            event.preventDefault();
            $('.js-join-date').hide("fast");
            $('.js-calendar').hide("fast");
            $('.search-button').trigger("click");
        }
    });
    /*
    $("input.js-page-number").keypress(function(event) {
        if (event.which == 13) {
            event.preventDefault();
        }
    });
    */

    $('.toggle-profile-section').click(function() {

        var dict = {
                'toggle-profile-topics': 'profile-topics-table',
                'toggle-profile-comments': 'profile-comments-table',
                'toggle-profile-upvotes': 'profile-upvotes-table',
                'toggle-profile-downvotes': 'profile-downvotes-table'
            },
            id = $(this).attr('id');

        // only shown on initial load
        $('#profile-activity-table').hide();

        $('.profile-table').each(function(i, item) {
            $(item).hide();
        });
        $('#' + dict[id]).show();
    });

    $('.js-search-on-change').on("change", function(){
        $('.search-button').trigger("click");
    });

    $('.js-clear-search').on("click", function(e){
        e.preventDefault();
        window.location.href="users.php";
        return false;
    });


    // Calendar logic   
    function populateCalendar(month, year) {
        $.ajax({
            method: 'GET',
            url: 'ajax/calendar.php?month='+month+'&year='+year
        })
        .done(function(res) {
            $('.js-calendar').html(res);

        });
    }

    // Load calendar with this month's date.
    var d = new Date();
    populateCalendar(d.getMonth()+1, d.getFullYear());

    $(document).on("click", '.js-calendar-next-month, .js-calendar-prev-month', function(e){
        e.preventDefault();
        year = $(this).data('year');
        month = $(this).data('month');
        populateCalendar(month, year);
    });

    $('.js-join-date').on("click", function(){
        $(this).parent().find('.pseudo-content').toggle('fast');
        $('.js-calendar').hide();
    });

    $('.js-open-calendar').on("click", function(){
        month = $(this).data('month');
        year = $(this).data('year');
        fromOrTo = $(this).data('item');
        if ($('.js-calendar').is(":visible") && wasFromOrTo == fromOrTo) {
            $('.js-calendar').hide('fast');
        } else {
            $('.js-calendar').hide('fast', function(){
                populateCalendar(month, year);
                $(this).show('fast');
            });
        }
        wasFromOrTo = fromOrTo;
    });

    $(document).on("click", ".js-calendar-date", function(){
        day = $(this).data('day');
        month = $(this).data('month');
        year = $(this).data('year');

        $('.js-date-'+fromOrTo).val(month+"/"+day+"/"+year);
        $('.js-calendar').toggle('fast');
        
        $('.search-button').trigger("click");

    });
});
