(function( $ ){

    var defaults = {
        'callback'       : '',
        'rowSelector'    : '',                 // selector for "row" to duplicate
        'addSelector'    : '',                 // selector for "add" button
        'removeSelector' : '',                 // selector of generic "remove" button
        'max'            : 0,                  // selector of generic "remove" button
        'effect'         : 'slide',            // use sliding effect for adding/removing
        'clearInputs'    : true,               // set whether to clear input elements

        'textElements'   : 'input[type="text"],input[type="password"],input[type="search"],textarea'

    };

    function duplicator(element, options) {
        this.element = $(element);
        this.options = $.extend(true, {}, defaults, options);
        this.init();
        if (!this.i)
            this.i = 0;
        this.i++;
    }

    duplicator.prototype.init = function () {

        var
        self             = this,
        rows             = this.element.find(this.options.rowSelector),
        original_element = rows.eq(0).clone(true, true);

        $.each(rows, function(i, row) {
            row = $(row);
            var row_parent = row.parent();

            if (row.data('empty') == '1') {
                row.remove();
            } else {
                self.addRemove(row);
            }
        });


        if (self.options.clearInputs) {
            original_element.find(self.options.textElements).val('');
            original_element.find('input[type="checkbox"]').attr('checked', false);
            original_element.find('input[type="radio"]').attr('checked', false);
            original_element.find('select').find('option:first').attr('selected', true);
        }

        self.element.find(self.options.addSelector).click(function(e) {
            e.preventDefault();

            if (self.options.max > 0) {
                if (self.element.find(self.options.rowSelector).size() == self.options.max)
                    return false;
            }

            var new_element = original_element.clone(true, true);
            self.addRemove(new_element);

            new_element.hide();
            self.element.append(new_element);
            if (self.options.effect == "slide") {
                new_element.css('opacity', 0.01);
                new_element.slideDown();
            }

            new_element.fadeTo('fast', 1);

            if (self.options.callback) {
                var callback = window[self.options.callback];
                callback(new_element);
            }

            return false;

        });

    }

    duplicator.prototype.addRemove = function(row) {
        var self = this;
        row.find(this.options.removeSelector).unbind().click(function() {
            if (self.options.effect == "slide") {
                row.fadeTo('fast', 0.01, function() {
                    row.slideUp(function(){
                        row.remove();
                    });
                });
            } else if (self.options.effect == "fade") {
                row.fadeOut(function() {
                    row.remove();
                });
            }
            return false;
        });
    }

  $.fn.duplicator = function (options) {
    return this.each(function () {
      if (!$.data(this, "duplicator")) {
        $.data(this, "duplicator", new duplicator(this, options));
      }
    });
  }

})( jQuery );
