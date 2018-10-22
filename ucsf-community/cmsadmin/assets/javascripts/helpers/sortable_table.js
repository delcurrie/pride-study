$(function() {
    var fixHelperModified = function(e, tr) {
        var $originals = tr.children();
        var $helper = tr.clone();
        $helper.children().each(function(index) {
            $(this).width($originals.eq(index).width())
        });
        return $helper;
    };

    $(".sortable-table").each(function() {
        var form = $(this).parents('form:first');
        $(this).find("tbody").sortable({
            helper: fixHelperModified,
            stop: function() {
                if (form.size() > 0) {
                    $.post(window.location.href, form.serialize());
                }
            }
        }).disableSelection();
    });
});
