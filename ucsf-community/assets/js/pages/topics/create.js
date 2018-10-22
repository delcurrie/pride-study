$(function() {

	var $topicCreateForm = $('.create-topic-form');

	$.extend($.validator.messages, {
    	required: "Required field",
    });

	$topicCreateForm.validateWrapper({
		submitOptions: {
			url: URL_BASE + 'community/topics/create',
			success: function(data) {
				AlertMessage('Post successful', false, 'OK', function() {
					setTimeout(function() {
						window.location.href = data.redirect;
					}, 1000);
				});

				return false;
			}
		},
		rules: {
			title: {
				required: true,
				minlength: 10,
			},
			description: {
				required: true,
				minlength: 10,
			},
			topic_categories: 'required'
		}
	});

});