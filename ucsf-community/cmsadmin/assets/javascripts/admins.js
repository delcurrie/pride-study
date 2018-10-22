$(function() {
        
    $('.js-clear-admin-search').hide();
    $('.js-search-admins').on("keyup", function(e){
        e.preventDefault();
        if ($(this).val() == '' ) {
            $('.js-clear-admin-search').hide();
        } else{
            $('.js-clear-admin-search').show();
        }
    })

    $('.js-clear-admin-search').on("click", function(e){
        e.preventDefault();
        $('.js-search-admins').val('').trigger("keyup");
        $(this).hide();
    });

    $.expr[":"].Contains = $.expr.createPseudo(function(arg) {
        return function( elem ) {
            return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
        };
    });

    $("#search_admins").keyup(function () {
        var data = this.value.split(" ");
        var tbl = $(".table").find("tr.table_row");
        console.log(this);
        if (this.value === "") {
            tbl.show();
            return;
        }
        tbl.hide();
        tbl.filter(function (i, v) {
            var t = $(this);
            for (var d = 0; d < data.length; d++) {
                if (t.is(":Contains('" + data[d] + "')")) {
                    return true;
                }
            }
            return false;
        }).show();
    });
});
