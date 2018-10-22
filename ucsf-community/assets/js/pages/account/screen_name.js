$(function() {

	var $createScreenNameForm = $('.create-screen-name-form');

	$createScreenNameForm.validateWrapper({
		submitOptions: {
			url: URL_BASE + 'account/screen-name',
			success: function(data) {
				AlertMessage('Screen name created successfully', false, 'OK', function() {				
					window.location.href = URL_BASE+'account/email-notifications';
				});
			}, 
			error: function(data) {
				console.log(data);
				
				if(data.duplicate) {
					AlertMessage('Screen name already taken. Please select a new one.', false, 'OK');
					return false;
				}
			}
		},
		rules: {
			screen_name: {
				required: true,
				minlength: 8
			},
		}
	});

});