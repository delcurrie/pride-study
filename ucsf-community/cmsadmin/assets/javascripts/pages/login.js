$(function() {
    var validator = $('form').validateWrapper({
        errorType: 'builtin',
        submitOptions: true,
        rules: {
            email : {
                required: true,
                email: true
            },
            password: "required"
        }
    });
});
