$(function() {
  var
  $showFilters = $('.js-filter-btn');
  $filters     = $('.filter-options');

  $showFilters.click(function(e) {
    e.preventDefault();

    $(this).toggleClass('filter-btn--active');
    $filters.toggleClass('filter-options--opened');

  });


  $("input").keypress(function(event) {
      if (event.which == 13) {
          event.preventDefault();
          $('.search-button').trigger("click");
      }
  });

  $('.js-clear-search').on("click", function(e){
  	e.preventDefault();
  	window.location.href="topics.php";
  	return false;
  });

});
