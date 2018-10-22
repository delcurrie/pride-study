$(function() {
	var validator = $('form').validateWrapper({
        errorType: 'builtin',
        submitOptions: true,
        rules: {
        	title: 'required',
        	description: 'required',
        	topic_category_id: 'required',
        }
    });

    $('.css-label').on("click", function(){
    	checkbox = $(this).prev();
    	checkbox.prop("checked", !checkbox.prop("checked"));
    });
});