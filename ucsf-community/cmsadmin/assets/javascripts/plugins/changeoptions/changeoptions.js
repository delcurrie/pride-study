;(function ($, undefined) {

    var defaults = {
        parent: {
            element: $([]),
            defaultText: 'Select',
            selected: null,

            data: [],
            dataKeyId: 'id',
            dataValueId: 'value'
        },
        child: {
            element: $([]),
            onHasOptions: null,
            onNoOptions: null,
            defaultText: 'Select',
            defaultEmptyText: 'Select Parent',
            selected: null,

            dataKey: 'data',
            dataKeyId: 'id',
            dataValueId: 'value',

            includeData: []
        },

        usePreExistingOptions: true,
        optionDataId: 'key',
    };

    function changeOptions(element, options) {
        this.element = $(element);
        this.options = $.extend(true, {}, defaults, options);
        this.init();
        if (!this.i)
            this.i = 0;
        this.i++;
    }

    changeOptions.prototype.init = function () {
        if (
                this.options.child.element.size() < 1
                ||
                (!this.options.usePreExistingOptions && this.options.parent.data.length < 1)) {
            return false;
        }

        this.options.parent.element = this.element;

        var self = this;
        if (!this.options.usePreExistingOptions) {
            this.element.html('<option value="">'+this.options.parent.defaultText+'</option>');
            this.options.child.element.html('<option value="">'+this.options.child.defaultText+'</option>');
            this.options.child.element.append('<option value="">'+this.options.child.defaultEmptyText+'</option>');

            var key = this.options.parent.dataKeyId;
            var value = this.options.parent.dataValueId;

            var ckey = this.options.child.dataKeyId;
            var cvalue = this.options.child.dataValueId;

            $.each(this.options.parent.data, function(i, v) {
                self.element.append('<option value="'+v[key]+'">'+v[value]+'</option>');
                var childData = v[self.options.child.dataKey];
                $.each(childData, function(ci, cv) {
                    var datahtml = '';
                    if (self.options.child.includeData.length > 0) {
                        $.each(self.options.child.includeData, function(di, dv) {
                            datahtml += ' data-'+dv+'="'+cv[dv]+'"';
                        });
                    }
                    self.options.child.element.append('<option value="'+cv[ckey]+'"'+datahtml+' data-'+self.options.optionDataId+'="'+v[key]+'">'+cv[cvalue]+'</option>');
                });
            });
        }

        if (this.element.data('selected'))
            this.options.parent.selected = this.element.data('selected');

        if (this.options.parent.selected)
            this.element.val(this.options.parent.selected);

        this.options.child.options = this.options.child.element.find('option');

        if (this.options.child.element.data('selected'))
            this.options.child.selected = this.options.child.element.data('selected');

        var selected = this.options.child.options.filter(':selected');
        if (selected.size() > 0 && !this.options.child.selected) {
            this.options.child.element.data('selected', selected.val());
        }
        if (this.options.child.options.eq(1).val() != '') {
            var clone = this.options.child.options.eq(0).clone(true, true);
            //var empty = $('<option value="" data-'+this.options.optionDataId+'="">'+this.options.child.defaultEmptyText+'</option>');
            clone.insertAfter(this.options.child.options.eq(0));
            this.options.child.options = this.options.child.element.find('option');
        }
        this.options.child.options.remove();

        if (this.options.child.selected) {
            this.options.child.element.val(this.options.child.selected);
            this.options.child.options.filter('[value="'+this.options.child.selected+'"]').attr('selected', true);
        }

        self = this;
        this.element.change(function() {
            var id = $(this).val();
            self.options.child.options.remove();

            var newOptions = self.options.child.options.filter('[data-'+self.options.optionDataId+'="'+id+'"]');

            if (newOptions.size() < 1 || id == '') {
                self.options.child.element.append(self.options.child.options.eq(1));
                if (id != '' && self.options.child.onNoOptions) {
                    self.options.child.onNoOptions();
                }
            } else {
                if (self.options.child.onHasOptions)
                  self.options.child.onHasOptions();
                self.options.child.element.append(self.options.child.options.eq(0))
                                          .append(newOptions);
            }
            self.options.child.element.trigger('change');
        }).trigger('change');

    };

    $.fn.changeOptions = function (options) {
        return this.each(function () {
            if (!$.data(this, "changeOptions")) {
                $.data(this, "changeOptions", new changeOptions(this, options));
            }
        });
    }

})(jQuery);