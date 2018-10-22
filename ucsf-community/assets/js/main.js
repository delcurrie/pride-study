$(document).ready(function() {

	var Nav = $('.nav');
	var NavBtns = $('.nav__icons');
	var NavBtn = $('.header__info');
	var NavToggle = 'nav--open';
	var NavBtnToggle = 'nav__icons--open';

	var Filters = $('.filters-panel--filters');
	var FiltersCategories = $('.filters-panel--categories');
	var FiltersBtn = $('.nav a.filters');
	var FilterButtons = $('.filters__btn');
	var FiltersToggle = 'filters--open';
	var FiltersCategoriesBack = $('.filters-panel--categories-back');

	var SearchBar = $('.nav__search');
	var SearchSubmit = $('.nav__search__btnsubmit');
	var SearchBtn = $('.nav a.search');
	var SearchBtnClose = $('.nav__search__btnclose');
	var SearchToggle = 'nav__search--open';

	var SearchOn = false;
	var NavOn = false;
	var FilterOn = false;

	NavBtn.click(function(e) {
		e.preventDefault();
		NavOn = !NavOn;
		Nav.toggleClass(NavToggle);
		closeNavSubs();
	});

	SearchBtn.click(function(e) {
		e.preventDefault();
		closeNavSubs();
		SearchOn = !SearchOn;
		SearchBar.toggleClass(SearchToggle);
		NavBtns.toggleClass(NavBtnToggle);
		SearchBar.find('.nav__search__input').focus();
	});

	SearchBtnClose.click(function(e) {
		e.preventDefault();
		SearchOn = false;
		SearchBar.removeClass(SearchToggle);
		NavBtns.addClass(NavBtnToggle);
		//Filters.removeClass(FiltersToggle);
	});

	SearchBar.keypress(handleSearchSubmit);
	SearchSubmit.keypress(handleSearchSubmit);
	SearchSubmit.click(function(e) {
		e.preventDefault();
		
		$(this).trigger({
			type: 'keypress',
			which: 13,
		});
	});

	/**
	 * Handle the search functionality
	 * 
	 * @param  e
	 */
	function handleSearchSubmit(e) {
		console.log(e);
		if(e.which == 13) {
	        var value = SearchBar.find('.nav__search__input').val();
	  //       var queryParams = getUrlVars();

	  //       queryParams['term'] = value;
	  //       if(queryParams['term'] == '') {
	  //       	delete queryParams['term'];
	  //       }

	  //       var url = '', i = 0;
	  //       for(var key in queryParams) {
			// 	i++;
			// 	url += (i > 1 ? '&' : '?') + key + '=' + queryParams[key];
			// }
			// var fullUrl = window.location.href.split('?')[0] + url;
			// window.location.href = fullUrl;
			
			window.location.href = URL_BASE + 'community?term=' + value;
	    }
	}

	FiltersBtn.click(function(e) {
		e.preventDefault();

		console.log($(this).data('filtered'));

		if (!$(this).data('filtered')) {		
			FiltersBtn.toggleClass('filters--on');
		}

		// Filters.toggleClass(FiltersToggle);
		Filters.slideToggle();

		// FiltersCategories.toggleClass(FiltersToggle);
		FiltersCategories.slideUp();
	});

	FiltersCategoriesBack.click(function(e) {
		e.preventDefault();
		FiltersCategories.removeClass(FiltersToggle);
		FiltersCategories.slideUp();

		Filters.addClass(FiltersToggle);
		Filters.slideDown();
		return false;
	});


	function closeNavSubs() {
		NavBtns.addClass(NavBtnToggle);
		SearchBar.removeClass(SearchToggle);
		Filters.removeClass(FiltersToggle);

		if (!FiltersBtn.data('filtered')) {		
			FiltersBtn.removeClass('filters--on');
		}
	}

	var $activityTabLink = $('.settings-panel__activity__item');

	$activityTabLink.click(function(e) {
		e.preventDefault();

		var listName = $(this).data('list'),
			$list = $('.settings-panel__activity__list--' + listName);

		$('.settings-panel__activity__item--active').removeClass('settings-panel__activity__item--active');
		$(this).addClass('settings-panel__activity__item--active');

		$('.settings-panel__activity__list--show').removeClass('settings-panel__activity__list--show');
		$list.addClass('settings-panel__activity__list--show');

		return false;
	});

	var $filterTypeButton = $('.filters__btn__type');
	var $filterTypeButtonSelected = $('.filters__btn__type--selected');
	var $filterLinksTitle = $('.filters__heading--category').hide();
	var $filterOrientations = $('.filters__orientation').hide();

	var $filterShowCategories = $('.filters__btn__type--show-categories');
	var $filterCategories = $('.filters-panel--categories');

	$filterShowCategories.click(function(e) {
		e.preventDefault();
		Filters.removeClass(FiltersToggle);
		Filters.slideUp();

		FiltersCategories.slideDown();
		FiltersCategories.addClass(FiltersToggle);
		return false;
	});

	$filterTypeButton.click(function(e) {
		e.preventDefault();

		var type = $(this).data('type');
		var typeName = type.charAt(0).toUpperCase() + type.slice(1);
		var typeText = typeName;

		if (typeText == 'Health') {
			typeText = 'a ' + typeText + ' Filter';
		}

		if (typeText == 'Age' || typeText == 'Identity') {
			typeText = 'An ' + typeText + ' Filter';
		}

		var title = 'Select ' + typeText;

		$filterLinksTitle.text(title).fadeIn();

		var $filterLinks = $('.filters__orientation--'+type);
		$filterLinks.slideDown()

		$('.filters__btn__type--selected').removeClass('filters__btn__type--selected');
		$(this).addClass('filters__btn__type--selected');

		$('.filters__orientation').addClass('filters__orientation--hide');
		$filterLinks.removeClass('filters__orientation--hide');

		return false;
	});

	$filterTypeButtonSelected.click();

	var $settingsSliderButton = $('.settings-panel__activity__item__scroller'),
		$settingsSliderNav 	  = $('.settings-panel__activity__inner__container');

	$settingsSliderButton.click(function(e) {
		e.preventDefault();

		if($(this).hasClass('settings-panel__activity__item__scroller--right')) {
			$settingsSliderNav.animate({
				'marginLeft' : "-=100%"
			}, 300);
		} else {
			$settingsSliderNav.animate({
				'marginLeft' : "+=100%"
			}, 300);
		}

		$(this).toggleClass('settings-panel__activity__item__scroller--right');

		return false;
	});

	var $backButton = $('.backbutton');

	$backButton.click(function(e) {		
		if($(this).hasClass('open-profile')) {
			e.preventDefault();
			window.location.href = URL_BASE + 'account/profile';
			return;
		}

		var useDefault = $(this).data('use-default') != 'true';
		if(useDefault) {
			e.preventDefault();
			window.history.back();
			return false;
		}
	});

	var $filterOverlay = $('.filter-overlay'),
		$filterOverlayOpen = $('.filters__help-btn'),
		$filterOverlayClose = $('.filter-overlay__close');

	$filterOverlayOpen.click(function(e) {
		e.preventDefault();
		$('body').addClass('noscroll');
		$('.main').addClass('noscroll');
		$filterOverlay.fadeIn();
		return false;
	});

	$filterOverlayClose.click(function(e) {
		e.preventDefault();
		$('body').removeClass('noscroll');
		$filterOverlay.fadeOut();
		return false;
	});

	FilterButtons.click(function(e) {
		e.preventDefault();

		var selected = $(this).hasClass('filters__btn--selected');
		$('.filters__btn--selected').removeClass('filters__btn--selected');
		
		if(!selected) {
			$(this).addClass('filters__btn--selected');
		}

		var href = $(this).attr('href');
		window.location.href = href;

		return false;
	});

});

var AlertMessage = function(message, button_link, button_text, callback) {

	var overlay = '<div class="alert-message"><div class="alert-message__container"><div class="alert-message__content"><p>' + message + '</p></div><a href="' + button_link + '" class="alert-message__close">' + button_text + '</a></div></div>';

	var $overlay = $(overlay).appendTo($('body')).show();

	if(!button_link) {
		$overlay.find('.alert-message__close').click(function(e) {
			e.preventDefault();
			$overlay.fadeOut(function() {
				if(callback) {
					callback();
				}
			});
			return false;
		});
	}
};