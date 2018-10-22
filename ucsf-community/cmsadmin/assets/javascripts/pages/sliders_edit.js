$(function() {
	var validator = $('form').validateWrapper({
        errorType: 'builtin',
        submitOptions: true,
        rules: {
        	text: 'required',
        	image: 'required',
        }
    });
});