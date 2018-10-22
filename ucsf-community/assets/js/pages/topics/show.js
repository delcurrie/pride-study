$(function() {

    // Fire topics loaded event to add event hooks
    $(document).trigger('topics.loaded');

	var $replyContainer = $('.reply'),
		$replyForm = $('.topic-reply-form');

    var $loadMore = $('.load-more-comments');

    /**
     * Handle click for the load more button
     */
    $loadMore.click(function(e) {
        e.preventDefault();

        var offset   = $loadMore.data('offset'),
            amount   = $loadMore.data('amount')
            id       = $loadMore.data('topic');

        loadComments(id, offset, amount, function(offset, amount) {
            $loadMore.data('offset', offset + amount);
        });

        return false;
    });

    $(document).on('comments.load', function() {
        var $comment = $('.comment-handle');
        $comment.click(function(e) {

            var $target = $(e.target);
            if(!$target.hasClass('comment-handle')) return;

            if($('body').hasClass('preview_mode')) {
                return;
            }
            
            $replyForm.find('input[type=submit]').val('Post Reply');
            $replyForm.find('textarea[name=message]').attr('placeholder', 'Post a reply here...');

            var $parent_field = $replyForm.find('input[name=parent_comment_id]'),
                parent_id = $(this).data('id');
            
            if($parent_field.length > 0) {
                $parent_field.val(parent_id);
            } else {
                $('<input>').attr({
                    type: 'hidden',
                    id: 'parent_comment_id',
                    name: 'parent_comment_id',
                    value: parent_id
                }).appendTo($replyForm);
            }

            if($(this).hasClass('comments__post')) {
                $replyContainer.insertAfter(this);
            } else if($(this).hasClass('postnav__btn--comment')) {
                $replyContainer.insertAfter($(this).parent().parent());
            }
        });
    });

	$replyForm.validateWrapper({
		submitOptions: {
			url: URL_BASE+'community/topics/comment',
			onSubmitSuccess: function(data) {
                if(data.added) {
                    window.location.reload();
                }
			}
		},
		rules: {
			// 'message': 'required',
			'topic_id': 'required'
		}
	});

    /**
     * Load topics using an ajax request
     */
    function loadComments(id, offset, limit, callback)
    {   
        var request = {
            offset: offset,
            amount: limit,
            topic_id: id
        };

        // Make get request to route
        $.get(URL_BASE+'community/topics/comment/get', request, 'json')
            .done(function(data) {

                data = JSON.parse(data);

                var html = data.html,
                    count = data.count,
                    last = data.last_page;

                var container = $('.comments');

                if(count > 0) {
                    $(html).hide().appendTo(container).fadeIn();
                    $(document).trigger('comments.load');
                    callback(offset, limit);
                }

                if(last) {
                    // AlertMessage('There are no more comments to load', false, 'OK');
                    $loadMore.fadeOut();
                }
                
            })
            .fail(function(data) {
                AlertMessage('Failed to load more comments, please try again.', false, 'OK');
            });
    }

    // Force click on load so we get first batch of comments
    $loadMore.click();
});