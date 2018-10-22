$(function() {
    var validator = $('form').validateWrapper({
        errorType: 'builtin',
        submitOptions: true,
        rules: {
            question       : "required",
            answer   : "required",
        }
    });
});
