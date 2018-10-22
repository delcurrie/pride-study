$(document).on('topics.loaded', function() {

	var Topics = $('.postcontainer');

    Topics.each(function() {
        var _self = $(this);
        var Posts = _self.find('.post:not(.post-loaded)');

        Posts.addClass('post-loaded');
        Posts.each(function() {

            var $post = $(this);
            var Ellipses = $post.find('.postnav__btn--ellipses');
            var Close = $post.find('.postbuttons__btn--close');

            Ellipses.on('click', function(e) {
                e.preventDefault();
                var thisOpen;
                if($(this).parent().parent().parent().hasClass('post--manage')) {
                    thisOpen = true;
                } else {
                    thisOpen = false;
                }

                $post.removeClass('post--manage');

                if(thisOpen) {
                    $(this).parent().parent().parent().removeClass('post--manage');
                } else {
                    $(this).parent().parent().parent().addClass('post--manage');
                }
            });

            Close.click(function(e) {
                e.preventDefault();
                $post.removeClass('post--manage');
                return false;
            });

            var $subscribe = $post.find('.subscribe-handle');
        
            $subscribe.click(function(e) {
                e.preventDefault();
                
                if($('body').hasClass('preview_mode')) {
                    AlertMessage('Create a screen name to begin participating in the community', false, 'OK');
                    return;
                }

                if($(this).data('can-subscribe') == false) {
                    AlertMessage('You cannot subscribe to this post.', false, 'OK');
                    return;
                }

                $.post(URL_BASE+'community/topics/subscribe', {topic_id: $(this).data('id')}, 'json').done(function(data) {
                    
                    data = JSON.parse(data);

                    if(data.subscribed === true) {
                        $subscribe.text('Unsubscribe');
                    } else {
                        $subscribe.text('Follow Conversation');
                    }
                    
                    setTimeout(function() {
                        Ellipses.click();
                    }, 500);

                });
                
                return false;
            });

            var $topicButtons = $post.find('.postnav__btn--topic:not(.postnav__btn--comment)');

            $topicButtons.click(function(e) {
                e.preventDefault();

                if($('body').hasClass('preview_mode')) {
                    AlertMessage('Create a screen name to begin participating in the community', false, 'OK');
                    return;
                }

                if($post.data('can-vote') == false) {
                    AlertMessage('You cannot vote on this topic.', false, 'OK');
                    return;
                }

                if($(this).hasClass('postnav__btn--up')) {
                    handleUpvote($(this));
                } else if($(this).hasClass('postnav__btn--dn')) {
                    handleDownvote($(this));
                }

                return false;
            });

            var $flagHandle = $post.find('.flag-handle');

            $flagHandle.click(function(e) {
                e.preventDefault();

                var id = $(this).data('id');

                var $handle = $(this);

                // Enabling unflagging if a user has 
                // flagged this topic themselves.
                if($handle.data('user-flagged')) {
                    $.post(URL_BASE+'community/topics/unflag', {topic_id: id}, 'json').done(function(data) {
                        data = JSON.parse(data);

                        if(data.unflagged) {
                            $flagHandle.text('Topic has been un-flagged');
                            setTimeout(function() {
                                Ellipses.click();
                                setTimeout(function() {
                                    $flagHandle.text('Flag as inappropriate');
                                    $handle.data('user-flagged', false);
                                }, 1000);
                            }, 500);
                        }

                    }); 

                    return;
                }
                
                if($('body').hasClass('preview_mode')) {
                    AlertMessage('Create a screen name to begin participating in the community.', false, 'OK');
                    return;
                }

                if($(this).data('can-flag') == false) {
                    AlertMessage('You cannot flag this post.', false, 'OK');
                    return;
                }
                
                if($(this).data('enabled')) {
                   $.post(URL_BASE+'community/topics/flag', {topic_id: id}, 'json').done(function(data) {
                        data = JSON.parse(data);

                        if(data.flagged) {
                            $flagHandle.text('Topic has been flagged');
                            $flagHandle.data('user-flagged', true);
                            setTimeout(function() {
                                Ellipses.click();
                                setTimeout(function() {
                                    $flagHandle.text('Already flagged');
                                }, 1000);
                            }, 500);
                        }

                    }); 
                }
                
                return false;
            });
        });

        /**
         * Handle upvoting
         * 
         * @param  object button
         * @return object
         */
        function handleUpvote(button) {

            var id = button.data('id'),
                value = button.data('value');

            $.post(URL_BASE+'community/topics/upvote', {topic_id: id}, 'json').done(function(data) {
                data = JSON.parse(data);

                if(data.upvoted === true) {
                    button.addClass('postnav__btn--active');
                } else {
                    button.removeClass('postnav__btn--active');
                }

                button.html('<span></span>' + data.upvoteCount);

                var downvoteButton = button.parent().find('.postnav__btn--dn');
                downvoteButton.removeClass('postnav__btn--active');
                downvoteButton.html('<span></span>' + data.downvoteCount);

            });
        }

        /**
         * Handle downvoting
         * 
         * @param  object button
         * @return object
         */
        function handleDownvote(button) {
            var id = button.data('id'),
                value = button.data('value');

            $.post(URL_BASE+'community/topics/downvote', {topic_id: id}, 'json').done(function(data) {
                data = JSON.parse(data);

                if(data.downvoted === true) {
                    button.addClass('postnav__btn--active');
                } else {
                    button.removeClass('postnav__btn--active');
                }

                button.html('<span></span>' + data.downvoteCount);
                
                var upvoteButton = button.parent().find('.postnav__btn--up');
                upvoteButton.removeClass('postnav__btn--active');
                upvoteButton.html('<span></span>' + data.upvoteCount);

            });
        }

    });

});