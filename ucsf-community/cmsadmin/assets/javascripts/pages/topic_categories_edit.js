$(function() {
	var validator = $('form').validateWrapper({
        errorType: 'builtin',
        submitOptions: true,
        rules: {
        	name: 'required'
        }
    });
});