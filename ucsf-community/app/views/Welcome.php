<?php $this->loadModule('Header'); ?>

<div class="intro main">   

    <div class="container">
        <div class="welcome-slider">
            <?php $i = 1; foreach($slides as $slide) : ?>
                <div class="welcome-slider__slide" data-slide-index="slide-dot-<?php echo $i; ?>">
                    <?php if($slide->getImage()) : ?>
                        <img class="intro__img" src="<?php echo $slide->getImage(true); ?>" />
                    <?php endif; ?>
                    <h2><?php echo $slide->getText(); ?></h2>
                </div>
            <?php $i++; endforeach; ?>
        </div>
    </div>

    <div class="intro__orange">
        <div class="intro__orange__inner">
            <div class="clearfix"></div>

            <div class="welcome-slider__dots__container">
                <h3>Swipe to learn more</h3>
                <ul class="welcome-slider__dots">
                    <?php foreach(range(1, count($slides)) as $i) : ?>
                        <li><a href="#" class="welcome-slider__dots__link <?php echo ($i == 1 ? 'welcome-slider__dots__link--active' : ''); ?>" id="slide-dot-<?php echo $i; ?>"></a></li>
                    <?php endforeach; ?>
                </ul>
            </div>

            <a href="<?php echo URL_BASE.'community'; ?>" class="button">Preview</a>
            <?php if(App::loggedIn()) : ?>
                <a href="<?php echo URL_BASE.'account/screen-name'; ?>" class="button">Create a Screen Name</a>
            <?php endif; ?>

<!--             <div class="signin"><p>Already a member? <a href="<?php echo URL_BASE.'account/login'; ?>">Sign in here</a>.</p></div> -->

        </div>
    </div>
</div>

<?php $this->loadModule('Footer'); ?>
