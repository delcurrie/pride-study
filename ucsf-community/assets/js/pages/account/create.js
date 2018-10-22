$(function() {

	var $createAccountForm = $('.create-account-form'),
		$passwordField = $createAccountForm.find('input[name=password]');

	$createAccountForm.validateWrapper({
		submitOptions: {
			url: URL_BASE + 'account/create'
		},
		rules: {
			username: {
				required: true,
				minlength: 4
			},
			email_address: {
				required: true,
				email: true,
			},
			password: {
				required: true,
				minlength: 5
			},
			password_confirmation: {
				required: true,
				equalTo: $passwordField
			},
		}
	});

});