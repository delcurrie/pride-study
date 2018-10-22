function initTinymce() {
    var tinymce_i = 1;
    $('textarea.tinymce').each(function() {

        var id = $(this).prop('id');
        if (!id) {
            id = 'tinymce'+tinymce_i;
            tinymce_i++;
            $(this).prop('id', id);
        }

        var settings = {
            selector: '#'+id,
            height: 400,
            plugins: [
                 "advlist autolink link image lists charmap print preview hr anchor pagebreak spellchecker",
                 "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking",
                 "save table contextmenu directionality emoticons template paste textcolor"
            ],
            relative_urls : false,
            custom_shortcuts : false,
            document_base_url : URL_BASE,
            external_plugins: {
                "moxiemanager": URL_BASE+"cmsadmin/assets/javascripts/plugins/tinymce/moxiemanager/editor_plugin.js"
            },
            content_css: HTTP_URL_BASE+'cmsadmin/assets/stylesheets/plugins/tinymce/content.css',
            style_formats: [],
            extended_valid_elements: 'span[class]'
        };

        $.each($(this).data(), function(k, v) {
            settings[k] = v;
        });

        tinymce.init(settings);
    });
}
initTinymce();
