$(function() {
    var ThumbnailListEl = $('.sortable-container ul');
    ThumbnailListEl.sortable({
        handle: 'img,.icon-reorder',
        update: function(event, ui) {
            $.post(window.location.href, ThumbnailListEl.sortable("serialize"));
        }
    });
});