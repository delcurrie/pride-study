$(function() {
    var validator = $('form').validateWrapper({
        errorType: 'builtin',
        submitOptions: true,
        rules: {
            name  : "required",
            email : {
                required: true,
                email: true
            },
            password: {
                required: {
                    depends: function(el) {
                        return !!!$(el).hasClass('optional');
                    }
                },
                pwcheck: true
            }
        }
    });
});
