$(function() {

	var $editAccountForm = $('.edit-account-form');

	$editAccountForm.validateWrapper({
		submitOptions: {
			url: URL_BASE + 'account/edit',
			success: function(data) {
				if(!data.revalidate) {
					AlertMessage('Profile Updated', false, 'OK');
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