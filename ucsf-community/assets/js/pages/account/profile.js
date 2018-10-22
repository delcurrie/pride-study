$(function() {
    var $loadNext = $('[data-load="next"]');

    $loadNext.click(function(e) {
        e.preventDefault();

        var $this = $(this),
            offset = $this.data('offset'),
            limit = $this.data('limit');

        $.get($this.attr('href'), {
            offset: offset,
            limit: limit
        }, 'json').done(function(data) {
            data = JSON.parse(data);

            var html = data.html,
                count = data.count,
                last = data.last;

            if (count > 0) {
                var $html = $(html).hide();

                $this.parent().before($html);
                $html.fadeIn();

                $this.data('offset', offset + limit);
                $(document).trigger('topics.loaded');
            }

            if(last) {
                // AlertMessage('No more posts to load.', false, 'OK');
                $this.fadeOut();
            }

        }).fail(function(data) {
            AlertMessage('Failed to load more posts, please try again.', false, 'OK');
        });
    });
});