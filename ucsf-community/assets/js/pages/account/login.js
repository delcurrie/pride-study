$(function() {

	var $loginForm = $('.login-form');

	$loginForm.validateWrapper({
		submitOptions: {
			url: URL_BASE + 'account/login'
		},
		rules: {
			username: 'required',
			password: 'required',
		}
	});

});