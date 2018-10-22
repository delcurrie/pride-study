$(function() {

    var $loadMore = $('.load-more-topics');

    /**
     * Handle click for the load more button
     */
    $loadMore.click(function(e) {
        e.preventDefault();

        var offset   = $loadMore.data('offset'),
            amount   = $loadMore.data('amount'),
            view     = $loadMore.data('view'),
            category = $loadMore.data('category');
            term     = $loadMore.data('term');

        loadTopics(offset, amount, view, category, term, function(offset, amount) {
            $loadMore.data('offset', offset + amount);
        });

        return false;
    });

    /**
     * Load topics using an ajax request
     */
    function loadTopics(offset, limit, view, category, term, callback)
    {   
        var request = {
            view: view || false,
            category: category || false,
            offset: offset,
            amount: limit,
            term: term
        };

        // Make get request to route
        $.get(URL_BASE+'community/topics/get', request, 'json')
            .done(function(data) {

                data = JSON.parse(data);

                var html = data.html,
                    count = data.count,
                    last = data.last_page;

                var container = $('.topic-container');

                if(count > 0) {
                    $(html).hide().appendTo(container).fadeIn();
                    callback(offset, limit);
                    $(document).trigger('topics.loaded');
                }

                if(last) {
                    // AlertMessage('No more posts to load.', false, 'OK');
                    $loadMore.fadeOut();
                }
                
            })
            .fail(function(data) {
                AlertMessage('Failed to load more posts, please try again.', false, 'OK');
            });
    }

    // Force click on load so we get first batch of posts
    $loadMore.click();

});