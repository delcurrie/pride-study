$(function() {

	var $welcomeSlider = $('.welcome-slider'),
		$slides        = $welcomeSlider.find('.welcome-slider__slide'),
		$dots  		   = $('.welcome-slider__dots__link');

	$welcomeSlider.slick({
		infinite: false,
  		slidesToShow: 1,
  		slidesToScroll: 1,
  		arrows: false
	});

	$welcomeSlider.on('afterChange', function(event, slick, currentSlide, nextSlide) {
		$('.welcome-slider__dots__link--active').removeClass('welcome-slider__dots__link--active');
		var id = '#slide-dot-' + (currentSlide + 1);
		$(id).addClass('welcome-slider__dots__link--active');
	});

	$dots.click(function(e) {
		e.preventDefault();

		var id = $(this).attr('id'),
			index = id.replace('slide-dot-', '') - 1;
			
		$welcomeSlider.slick('slickGoTo', index);

		return false;
	});
});