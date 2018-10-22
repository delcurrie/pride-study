$(document).on('comments.load', function() {
	
	var $buttons = $('.postnav__btn--cmmt');

	$buttons.click(function(e) {
		e.preventDefault();
		
		var $comment = $(this).parent().parent();

		if($('body').hasClass('preview_mode')) {
			AlertMessage('Create a screen name to begin participating in the community', false, 'OK');
			return;
		}

		if($(this).hasClass('postnav__btn--flag')) {

			if($comment.data('can-flag') == false) {
				AlertMessage('You cannot flag this comment.', false, 'OK');
				return;
			}

			if($comment.data('is-users') == true) {
                AlertMessage('You cannot flag your own comment.', false, 'OK');
                return;
            }

        	handleFlag($comment, $(this));

        } else if($(this).hasClass('postnav__btn--comment')) {

        	if($comment.data('can-reply') == false) {
        		var msg = 'You can not reply to this comment.';

        		if($comment.data('is-reply')) {
        			msg = 'You can not reply to this reply.';
        		}

        		AlertMessage(msg, false, 'OK');
                return;
        	}

        } else {

        	if($comment.data('is-users') == true) {
                AlertMessage('You cannot vote on your own comment.', false, 'OK');
                return;
            }

        	if($comment.data('can-vote') == false) {
                AlertMessage('You can not vote on this comment.', false, 'OK');
                return;
            }

        	if($(this).hasClass('postnav__btn--up')) {
            	handleUpvote($comment, $(this));
	        } else if($(this).hasClass('postnav__btn--dn')) {
	            handleDownvote($comment, $(this));
	        }
        }
	
		return false;
	});

	/**
	 * Handle upvoting a comment
	 * 
	 * @param  comment
	 * @param  button
	 */
	function handleUpvote(comment, button)
	{
		var id = comment.data('id'),
            count = button.data('value');

        $.post(URL_BASE+'community/topics/comment/upvote', {comment_id: id}, 'json').done(function(data) {
        	data = JSON.parse(data);

        	if(data.upvoted === true) {
                button.addClass('postnav__btn--active');
            } else {
                button.removeClass('postnav__btn--active');
            }

            button.html('<span></span>' + data.upvoteCount);

            var downvoteButton = comment.find('.postnav__btn--dn');
            downvoteButton.removeClass('postnav__btn--active');
            downvoteButton.html('<span></span>' + data.downvoteCount);
        });
	}

	/**
	 * Handle downvoting a comment
	 * 
	 * @param  comment
	 * @param  button
	 */
	function handleDownvote(comment, button)
	{
		var id = comment.data('id'),
            count = button.data('value');

        $.post(URL_BASE+'community/topics/comment/downvote', {comment_id: id}, 'json').done(function(data) {
        	data = JSON.parse(data);

        	if(data.downvoted === true) {
                button.addClass('postnav__btn--active');
            } else {
                button.removeClass('postnav__btn--active');
            }

            button.html('<span></span>' + data.downvoteCount);

            var upvoteButton = comment.find('.postnav__btn--up');
            upvoteButton.removeClass('postnav__btn--active');
            upvoteButton.html('<span></span>' + data.upvoteCount);
        });
	}

	/**
	 * Handle flagging a comment
	 * 
	 * @param  comment
	 * @param  button 
	 */
	function handleFlag(comment, button)
	{
		var id = comment.data('id');

		if (comment.data('user-flagged')) {
			$.post(URL_BASE+'community/topics/comment/unflag', {comment_id: id}, 'json').done(function(data) {
				data = JSON.parse(data);

				if(data.unflagged === true) {
					button.removeClass('postnav__btn--active');
					comment.data('user-flagged', false);
				} else {
					button.addClass('postnav__btn--active');
				}
			});
		} else {
			$.post(URL_BASE+'community/topics/comment/flag', {comment_id: id}, 'json').done(function(data) {
				data = JSON.parse(data);

				if(data.flagged === true) {
					button.addClass('postnav__btn--active');
					comment.data('user-flagged', true);
				} else {
					button.removeClass('postnav__btn--active');
				}
			});
		}
		
	}

});