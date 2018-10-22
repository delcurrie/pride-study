(function() {
    $(document).ready(function() {
        var body, click_event, content, nav, nav_toggler;
        nav_toggler = $("header .toggle-nav");
        nav = $("#main-nav");
        content = $("#content");
        body = $("body");
        click_event = (jQuery.support.touch ? "tap" : "click");
        $("#main-nav .dropdown-collapse").on(click_event, function(e) {
            var link, list;
            e.preventDefault();
            link = $(this);
            list = link.parent().find("> ul");
            if (list.is(":visible")) {
                if (body.hasClass("main-nav-closed") && link.parents("li").length === 1) {
                    return false;
                } else {
                    link.removeClass("in");
                    list.slideUp(300, function() {
                        return $(this).removeClass("in");
                    });
                }
            } else {
                if (list.parents("ul.nav.nav-stacked").length === 1) {
                    $(document).trigger("nav-open");
                }
                link.addClass("in");
                list.slideDown(300, function() {
                    return $(this).addClass("in");
                });
            }
            return false;
        });
        if (jQuery.support.touch) {
            nav.on("swiperight", function(e) {
                return $(document).trigger("nav-open");
            });
            nav.on("swipeleft", function(e) {
                return $(document).trigger("nav-close");
            });
        }
        nav_toggler.on(click_event, function() {
            if (nav_open()) {
                $(document).trigger("nav-close");
            } else {
                $(document).trigger("nav-open");
            }
            return false;
        });
        $(document).bind("nav-close", function(event, params) {
            body.removeClass("main-nav-opened").addClass("main-nav-closed");
            return false;
        });
        return $(document).bind("nav-open", function(event, params) {
            body.addClass("main-nav-opened").removeClass("main-nav-closed");
            return true;
        });
    });

    this.nav_open = function() {
        return $("body").hasClass("main-nav-opened") || $("#main-nav").width() > 50;
    };

    $(document).ready(function() {
        var touch;
        setUploadify();
        setTimeAgo();
        setScrollable();
        setSortable($(".sortable"));
        setSelect2();
        setAutoSize();
        setCharCounter();
        setMaxLength();
        setValidateForm();
        $(".box .box-remove").live("click", function(e) {
            $(this).parents(".box").first().remove();
            e.preventDefault();
            return false;
        });
        $(".box .box-collapse").live("click", function(e) {
            var box;
            box = $(this).parents(".box").first();
            box.toggleClass("box-collapsed");
            e.preventDefault();
            return false;
        });
        if (jQuery().pwstrength) {
            $('.pwstrength').pwstrength({
                showVerdicts: false
            });
        }
        $(".check-all").live("click", function(e) {
            return $(this).parents("table:eq(0)").find(".only-checkbox :checkbox").attr("checked", this.checked);
        });
        if (jQuery().tabdrop) {
            $('.nav-responsive.nav-pills, .nav-responsive.nav-tabs').tabdrop();
        }
        setDataTable($(".data-table"));
        setDataTable($(".data-table-column-filter"));
        if (jQuery().wysihtml5) {
            $('.wysihtml5').wysihtml5();
        }
        if (jQuery().nestable) {
            $('.dd-nestable').nestable({
                allowCrossDepth: false
            });
        }
        if (!$("body").hasClass("fixed-header")) {
            if (jQuery().affix) {
                $('#main-nav.main-nav-fixed').affix({
                    offset: 40
                });
            }
        }
        touch = false;
        if (window.Modernizr) {
            touch = Modernizr.touch;
        }
        if (!touch) {
            $("body").on("mouseenter", ".has-popover", function() {
                var el;
                el = $(this);
                if (el.data("popover") === undefined) {
                    el.popover({
                        placement: el.data("placement") || "top",
                        container: "body"
                    });
                }
                return el.popover("show");
            });
            $("body").on("mouseleave", ".has-popover", function() {
                return $(this).popover("hide");
            });
        }
        touch = false;
        if (window.Modernizr) {
            touch = Modernizr.touch;
        }
        if (!touch) {
            $("body").on("mouseenter", ".has-tooltip", function() {
                var el;
                el = $(this);
                if (el.data("tooltip") === undefined) {
                    el.tooltip({
                        placement: el.data("placement") || "top",
                        container: "body"
                    });
                }
                return el.tooltip("show");
            });
            $("body").on("mouseleave", ".has-tooltip", function() {
                return $(this).tooltip("hide");
            });
        }
        if (window.Modernizr && Modernizr.svg === false) {
            $("img[src*=\"svg\"]").attr("src", function() {
                return $(this).attr("src").replace(".svg", ".png");
            });
        }
        if (jQuery().colorpicker) {
            $(".colorpicker-hex").colorpicker({
                format: "hex"
            });
            $(".colorpicker-rgb").colorpicker({
                format: "rgb"
            });
        }
        if (jQuery().datetimepicker) {
            $(".datetimepicker").datetimepicker();
            $(".datepicker").datetimepicker({
                pickTime: false
            });
            $(".timepicker").datetimepicker({
                pickDate: false
            });
        }
        if (jQuery().bootstrapFileInput) {
            $('input[type=file]').bootstrapFileInput();
        }
        if (jQuery().changeOptions) {
            (function($) {
                var FilterTypes = {};
                var FilterTypeFallbacks = {};
                var Filters = $('select.Filter');
                var FilterChildren = {};
                var FilterFallbacks = {};
                var FilterTypeCount = {};
                Filters.each(function() {
                    var FilterName = $(this).data('filterName');
                    var ChildName = $(this).data('childName');
                    if (!FilterChildren[ChildName]) {
                        FilterChildren[ChildName] = $('select.Filter'+ChildName);
                        FilterFallbacks[ChildName] = $('.Filter'+ChildName+'Fallback');
                        FilterTypeCount[ChildName] = 0;
                    } else {
                        FilterTypeCount[ChildName]++;
                    }
                    var Child = FilterChildren[ChildName].eq(FilterTypeCount[ChildName]);
                    var Fallback = FilterFallbacks[ChildName].eq(FilterTypeCount[ChildName]).hide();

                    $(this).changeOptions({
                        parent: {
                            defaultText: 'Select',
                        },
                        child: {
                            defaultText: 'Select',
                            defaultEmptyText: 'Select',
                            element: Child,
                            onNoOptions: function() {
                                Fallback.show();
                                Child.hide();
                            },
                            onHasOptions: function() {
                                Fallback.hide();
                                Child.show();
                            }
                        },
                        usePreExistingOptions: true,
                        optionDataId: FilterName
                    });
                });
            })(jQuery);
        }
        if (jQuery().duplicator) {
            $('.duplicator').each(function() {
                var settings = $(this).data();
                $(this).duplicator(settings);
            });
        }
        if (window.Modernizr) {
            if (!Modernizr.input.placeholder) {
                $("[placeholder]").focus(function() {
                    var input;
                    input = $(this);
                    if (input.val() === input.attr("placeholder")) {
                        input.val("");
                        return input.removeClass("placeholder");
                    }
                }).blur(function() {
                    var input;
                    input = $(this);
                    if (input.val() === "" || input.val() === input.attr("placeholder")) {
                        input.addClass("placeholder");
                        return input.val(input.attr("placeholder"));
                    }
                }).blur();
                return $("[placeholder]").parents("form").submit(function() {
                    return $(this).find("[placeholder]").each(function() {
                        var input;
                        input = $(this);
                        if (input.val() === input.attr("placeholder")) {
                            return input.val("");
                        }
                    });
                });
            }
        }

        $('.pseudo-expand').on('click', function() {
            var $this = $(this),
                icon = $(this).find('img').attr('src'),
                up = 'assets/images/icons/gray-carrot-up.svg',
                down = 'assets/images/icons/gray-carrot-down.svg',
                activeUp = 'assets/images/icons/white-carrot-up.svg',
                activeDown = 'assets/images/icons/white-carrot-down.svg',
                checkboxes = [
                    'participants-active',
                    'participants-banned',
                    'participants-withdrawn'
                ];

            if (icon == up || icon == activeUp) {
                $this.find('img').attr('src', down);
                for (var i=0; i<checkboxes.length; i++) {
                    if ($('#' + checkboxes[i] + ':checked').length > 0) {
                        $this.closest('.pseudo').addClass('active');
                        $this.find('img').attr('src', activeDown);
                        break;
                    }
                    $this.closest('.pseudo').removeClass('active');
                }
            } else {
                $this.find('img').attr('src', up);
                if($this.closest('.pseudo').hasClass('active'))
                    $this.find('img').attr('src', activeUp);
            }

            $this.closest('.pseudo')
                .find('.pseudo-content')
                .toggle();
        });

        $("input").keypress(function(event) {
            if (event.which == 13) {
                event.preventDefault();
                $("form").submit();
            }
        });

    });

    this.setUploadify = function(selector) {
        if (selector === undefined) {
            selector = $("input[type=file].uploadify");
        }
        if (jQuery().uploadify) {
            selector.each(function() {
                var
                File    = $(this),
                Field   = File.parent(),
                Details = Field.find('.details:first'),
                Hidden  = Details.find('input[type=hidden]:first'),
                Title    = File.attr('title'),
                Name    = File.attr('name'),
                isImage = File.hasClass('Image'),
                multi = File.hasClass('multiple'),
                callback = File.data('callback');

                if (!File.attr('id'))
                File.attr('id', Name);

                Details.find('.remove').click(function() {
                    Hidden.remove();
                    Details.html('').append(Hidden);
                    Hidden.val('');
                    return false;
                });
                File.uploadifive({
                    auto: true,
                    buttonClass: 'btn',
                    buttonText: 'Upload',
                    fileObjName: Name,
                    fileType: (isImage?'image':''),
                    multi: multi,
                    removeCompleted: true,
                    removeTimeout: 0,
                    uploadScript: window.location.href,
                    onUploadComplete: function(file, data) {
                        if (callback) {
                            var fn = window[callback];
                            fn(file, data);
                        } else {
                            Details.html(data).removeClass('Hide');
                            Details.find('script').each(function() {
                                eval($(this).text());
                            });
                        }
                    },
                    onFallback: function() {
                        File.uploadify({
                            auto: true,
                            buttonClass: 'btn',
                            buttonText: 'Upload',
                            fileObjName: Name,
                            fileTypeDesc: (isImage?'Images Only':'All Files'),
                            fileTypeExts: (isImage?'*.gif; *.jpg; *.png':'*.*'),
                            formData: window.SessionInfo,
                            multi: multi,
                            removeCompleted: true,
                            removeTimeout: 0,
                            swf: 'assets/swf/plugins/uploadify/uploadify.swf',
                            uploader: window.location.href,
                            onUploadSuccess: function(file, data, response) {
                                if (callback) {
                                    var fn = window[callback];
                                    fn(file, data);
                                } else {
                                    Details.html(data).removeClass('Hide');
                                    Details.find('script').each(function() {
                                        eval($(this).text());
                                    });
                                }
                            }
                        });
                    }
                });
            });
        }
    };

    this.setMaxLength = function(selector) {
        if (selector === undefined) {
            selector = $(".char-max-length");
        }
        if (jQuery().maxlength) {
            return selector.maxlength();
        }
    };

    this.setCharCounter = function(selector) {
        if (selector === undefined) {
            selector = $(".char-counter");
        }
        if (jQuery().charCount) {
            return selector.charCount({
                allowed: selector.data("char-allowed"),
                warning: selector.data("char-warning"),
                cssWarning: "text-warning",
                cssExceeded: "text-error"
            });
        }
    };

    this.setAutoSize = function(selector) {
        if (selector === undefined) {
            selector = $(".autosize");
        }
        if (jQuery().autosize) {
            return selector.autosize();
        }
    };

    this.setTimeAgo = function(selector) {
        if (selector === undefined) {
            selector = $(".timeago");
        }
        if (jQuery().timeago) {
            jQuery.timeago.settings.allowFuture = true;
            jQuery.timeago.settings.refreshMillis = 60000;
            selector.timeago();
            return selector.addClass("in");
        }
    };

    this.setScrollable = function(selector) {
        if (selector === undefined) {
            selector = $(".scrollable");
        }
        if (jQuery().slimScroll) {
            return selector.each(function(i, elem) {
                return $(elem).slimScroll({
                    height: $(elem).data("scrollable-height"),
                    start: $(elem).data("scrollable-start") || "top"
                });
            });
        }
    };

    this.setSortable = function(selector) {
        if (selector === undefined) {
            selector = null;
        }
        if (selector) {
            return selector.sortable({
                axis: selector.data("sortable-axis"),
                connectWith: selector.data("sortable-connect")
            });
        }
    };

    this.setSelect2 = function(selector) {
        if (selector === undefined) {
            selector = $(".select2");
        }
        if (jQuery().select2) {
            return selector.each(function(i, elem) {
                return $(elem).select2();
            });
        }
    };

    this.setDataTable = function(selector) {
        if (jQuery().dataTable) {
            return selector.each(function(i, elem) {
                var dt, sdom;
                if ($(elem).data("pagination-top-bottom") === true) {
                    sdom = "<'row datatables-top'<'col-sm-6'l><'col-sm-6 text-right'pf>r>t<'row datatables-bottom'<'col-sm-6'i><'col-sm-6 text-right'p>>";
                } else if ($(elem).data("pagination-top") === true) {
                    sdom = "<'row datatables-top'<'col-sm-6'l><'col-sm-6 text-right'pf>r>t<'row datatables-bottom'<'col-sm-6'i><'col-sm-6 text-right'>>";
                } else {
                    sdom = "<'row datatables-top'<'col-sm-6'l><'col-sm-6 text-right'f>r>t<'row datatables-bottom'<'col-sm-6'i><'col-sm-6 text-right'p>>";
                }
                dt = $(elem).dataTable({
                    sDom: sdom,
                    sPaginationType: "bootstrap",
                    "iDisplayLength": $(elem).data("pagination-records") || 10,
                    oLanguage: {
                        sLengthMenu: "_MENU_ records per page"
                    }
                });
                if ($(elem).hasClass("data-table-column-filter")) {
                    dt.columnFilter();
                }
                dt.closest('.dataTables_wrapper').find('div[id$=_filter] input').css("width", "200px");
                return dt.closest('.dataTables_wrapper').find('input').addClass("form-control input-sm").attr('placeholder', 'Search');
            });
        }
    };

    this.setValidateForm = function(selector) {
        if (selector === undefined) {
            selector = $(".validate-form");
        }
        if (jQuery().validate) {
            return selector.each(function(i, elem) {
                return $(elem).validate({
                    errorElement: "span",
                    errorClass: "help-block has-error",
                    errorPlacement: function(e, t) {
                        return t.parents(".controls").first().append(e);
                    },
                    highlight: function(e) {
                        return $(e).closest('.form-group').removeClass("has-error has-success").addClass('has-error');
                    },
                    success: function(e) {
                        return e.closest(".form-group").removeClass("has-error");
                    }
                });
            });
        }
    };

}).call(this);

function slugify(text) {
    return text.toString().toLowerCase()
    .replace(/\s+/g, '-')           // Replace spaces with -
    .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
    .replace(/\-\-+/g, '-')         // Replace multiple - with single -
    .replace(/^-+/, '')             // Trim - from start of text
    .replace(/-+$/, '');            // Trim - from end of text
}

function errorPlacement(error, element) {

    var
    elem    = $(element),
    corners = ['left center', 'right center'];

    if (error.text().indexOf('decline') > -1) {
        corners = ['bottom center', 'top center'];
    } else if (elem.hasClass('qtiptop')) {
        corners = ['bottom center', 'top center'];
    } else if (elem.hasClass('qtipleft')) {
        corners = ['right center', 'left center'];
    }

    var qtipel = elem.filter(':not(.valid)');
    var tooltipel = elem.data('tooltip');
    if (tooltipel)
    qtipel = $(tooltipel);

    if (!error.is(':empty')) {
        qtipel.qtip({
            overwrite: false,
            content: error,
            position: {
                my: corners[0],
                at: corners[1]
            },
            show: {
                event: false,
                ready: true
            },
            hide: false,
            style: {
                classes: 'qtip-red'
            }
        }).qtip('option', 'content.text', error);
    } else {
        qtipel.qtip('destroy');
    }
}

;(function ($, undefined) {

    // Create the defaults, only once!
    var defaults = {};

    var errortype_defaults = {};
    errortype_defaults.tooltips = {
        errorClass     : 'error',
        validClass     : 'valid',
        errorPlacement : errorPlacement,
        success        : $.noop
    };

    errortype_defaults.singlelist = {
        errorClass          : 'error',
        validClass          : 'valid',
        errorContainer      : '.FormErrors',
        errorLabelContainer : '.FormErrors ul',
        wrapper             : 'li'
    };

    errortype_defaults.builtin = {
        errorClass: "help-block has-error",
        highlight: function(e) {
            return $(e).closest('.form-group').removeClass("has-error has-success").addClass('has-error');
        },
        success: function(e) {
            return e.closest(".form-group").removeClass("has-error");
        },
        errorPlacement: function (label, element) {
            if (element.is('input[type="file"]')) {
                label.insertAfter(element.parent());
            } else if (element.hasClass('pwstrength')) {
                label.insertAfter(element.next());
            } else {
                label.insertAfter(element);
            }
        }
    };

    $.fn.validateWrapper = function (options) {

        options = $.extend({}, defaults, options);

        if (typeof options.errorType === 'undefined' || options.errorType === '') {
            options.errorType = 'tooltips';
            delete options.messages;
        }

        if (options.errorType == 'singlelist') {
            var
            validateErrorContainer = $(options.errorContainer);
            if (validateErrorContainer.size()) {
                validateErrorContainer.append('<ul></ul>');
            } else {
                console.log('validateWrapper: Missing Error Container');
                options.errorType = 'builtin';
            }
        }

        options = $.extend({}, errortype_defaults[options.errorType], options);
        delete options.errorType;

        $(this[0]).submit(function() {
            if (typeof tinymce != "undefined") {
                tinymce.triggerSave();
            }
        });

        if (options.submitOptions) {
            $(this[0]).attr('action', '#').attr('method', 'get');
            var submitRequest;
            options.submitHandler = function(form) {
                var
                post_data   = $(form).serialize(),
                button      = $(form).find('button[type="submit"]'),
                button_html = button.html();

                button.html('<i class="icon-time"></i> Saving...').attr('disabled', true);

                if (post_data.indexOf('preview=1') > -1) {
                    window.open('about:blank', 'preview');
                }
                try {
                    submitRequest.stop();
                } catch (e) {}

                submitRequest = $.ajax({
                    method   : 'post',
                    url      : (options.submitOptions.url?options.submitOptions.url:window.location.href),
                    data     : post_data,
                    dataType : 'html',
                    success  : function(data) {
                        try {
                            data = $.parseJSON(data);
                        } catch (e) {
                            console.log(e.message);
                            console.log(data);
                            return;
                        }

                        button.html(button_html).attr('disabled', false);

                        if ((data.errors && Object.size(data.errors) > 0) || data.revalidate) {

                            if (data.revalidate)
                            $(form).valid();

                            if (data.errors && Object.size(data.errors) > 0)
                            validator.showErrors(data.errors);

                        } else {
                            if (data.preview) {
                                window.open(data.preview, 'preview');
                            }

                            if (options.submitOptions.success && !options.submitOptions.success(data))
                            return;

                            if(data.redirect) {
                                window.location.href = data.redirect;
                            } else {
                                window.location.reload();
                            }

                        }
                    }
                });
            };
        }

        if (typeof tinymce != "undefined") {
            options.focusInvalid = function() {
                // put focus on tinymce on submit validation
                if (this.settings.focusInvalid) {
                    try {
                        var toFocus = $(this.findLastActive() || this.errorList.length && this.errorList[0].element || []);
                        if (toFocus.is("textarea") && toFocus.hasClass('tinymce')) {
                            tinymce.get(toFocus.attr("id")).focus();
                        } else {
                            toFocus.filter(":visible").focus();
                        }
                    } catch (e) {
                        // ignore IE throwing errors when focusing hidden elements
                    }
                }
            };
        }

        var validator = $(this[0]).validate(options);
        return validator;
    };

})(jQuery);

$(function() {
    if ($.validator) {

        $.validator.prototype.checkForm = function() {
            this.prepareForm();
            for ( var i = 0, elements = (this.currentElements = this.elements()); elements[i]; i++ ) {
                if (this.findByName( elements[i].name ).length !== undefined && this.findByName( elements[i].name ).length > 1) {
                    for (var cnt = 0; cnt < this.findByName( elements[i].name ).length; cnt++) {
                        this.check( this.findByName( elements[i].name )[cnt] );
                    }
                } else {
                    this.check( elements[i] );
                }
            }
            return this.valid();
        };

        $.validator.defaults.ignore = function() {
            if ($(this).attr('type') == 'hidden' || $(this).hasClass('tinymce')) {
                return !$(this).parent().is(':hidden');
            } else {
                return !$(this).is(':hidden');
            }
        };

        $.validator.prototype.elements = function() {
            var validator = this,
            rulesCache = {};

            // select all valid inputs inside the form (no submit or reset buttons)
            var elements =
            $(this.currentForm)
            .find("input, select, textarea")
            .not(":submit, :reset, :image, [disabled]");
            if (typeof this.settings.ignore == "function") {
                elements = elements.filter(this.settings.ignore);
            } else {
                elements = elements.not( this.settings.ignore );
            }
            elements = elements.filter(function() {
                if ( !this.name && validator.settings.debug && window.console ) {
                    console.error( "%o has no name assigned", this);
                }

                // select only the first element for each name, and only those with rules specified
                if ( this.name in rulesCache || !validator.objectLength($(this).rules()) ) {
                    return false;
                }

                rulesCache[this.name] = true;
                return true;
            });
            return elements;
        };

        $.validator.prototype.validationTargetFor = function(element) {
            // if radio/checkbox, validate first element in group instead
            if ( this.checkable(element) ) {
                element = this.findByName( element.name );
                if (typeof this.settings.ignore == "function") {
                    element = element.filter(this.settings.ignore);
                } else {
                    element = element.not(this.settings.ignore);
                }
                element = element[0];
            }
            return element;
        };

        $.validator.addMethod("pwcheck", function(value, element) {
            return this.optional(element) || /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$/.test(value);
        }, "Must contain minimum of 8 characters, upper and lowercase letters and at least one number.");
    }

    if (typeof tinymce === "undefined") {
        $('.tinymce').removeClass('tinymce');
    }

    $('.cancel').click(function() {
        parent.history.back();
		return false;
    });

});

/*
* Replace all SVG images with inline SVG
*/
jQuery('img.svg').each(function(){
    var $img = jQuery(this);
    var imgID = $img.attr('id');
    var imgClass = $img.attr('class');
    var imgURL = $img.attr('src');

    jQuery.get(imgURL, function(data) {
        // Get the SVG tag, ignore the rest
        var $svg = jQuery(data).find('svg');

        // Add replaced image's ID to the new SVG
        if(typeof imgID !== 'undefined') {
            $svg = $svg.attr('id', imgID);
        }
        // Add replaced image's classes to the new SVG
        if(typeof imgClass !== 'undefined') {
            $svg = $svg.attr('class', imgClass+' replaced-svg');
        }

        // Remove any invalid XML tags as per http://validator.w3.org
        $svg = $svg.removeAttr('xmlns:a');

        // Replace image with new SVG
        $img.replaceWith($svg);

    }, 'xml');

});

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};
