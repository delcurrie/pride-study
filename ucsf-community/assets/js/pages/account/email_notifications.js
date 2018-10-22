$(function() {

	var $emailNotificationsForm = $('.set-email-notifications-form');

	$emailNotificationsForm.validateWrapper({
		submitOptions: {
			url: URL_BASE + 'account/email-notifications',
			success: function(data) {
				if (!data.revalidate) {
					AlertMessage('Email notification settings saved.', false, 'OK', function() {					
						window.location.href = URL_BASE + 'community';
					});
				}
			}
		},
	});

});