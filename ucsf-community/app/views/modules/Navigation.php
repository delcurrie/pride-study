<div class="nav nav--off nav--open <?php echo ($this->is_logged_in ? 'nav--signed' : ''); ?>">
    
    <div class="nav__search">
        <a href="#" class="nav__search__btnclose "></a>
        <a href="#" class="nav__search__btnsubmit"></a>
        <input class="nav__search__input" type="search" value="<?php echo $_GET['term']; ?>"/>
    </div>

    <div class="nav__inner">
        <div class="nav__icons nav__icons--open">
            <?php if($this->show_back) : ?>
                <?php 
                    $back_url = URL_BASE . 'community';
                    if(isset($_GET['back_url'])) {      
                        $back_url = $_GET['back_url'];
                    }
                ?>
                <a href="<?php echo $back_url; ?>" class="backbutton <?php echo (isset($_GET['back_profile']) ? 'open-profile' : ''); ?>" data-use-default="<?php echo (isset($_GET['back_url']) ? 'false' : ''); ?>"></a>
            <?php endif;?>

            <a href="<?php echo URL_BASE; ?>community" class="home"></a>
            
            <?php if(App::loggedIn() && $this->show_create_screen_name) : ?>
                <a href="<?php echo URL_BASE.'account/screen-name'; ?>" class="get-started">create a screen name</a>
            <?php endif; ?>

            <?php if(App::loggedIn() && $this->show_profile) : ?>
                <a href="<?php echo URL_BASE; ?>account/profile" class="settings <?php echo ($this->is_profile_view ? 'settings--on' : ''); ?>"></a>
            <?php endif; ?>

            <?php if($this->show_filters) : $filtered = isset($_GET['view']) || isset($_GET['category']); ?>
                <a href="#" data-filtered="<?php echo ($filtered ? 'true' : 'false'); ?>" class="filters <?php echo ($filtered ? 'filters--on' : ''); ?>"></a>
            <?php endif;?>

            <a href="#" class="search"></a>
            <div class="clearfix"></div>
        </div>
    </div>

</div>

<?php if($this->show_filters) : ?>

<div class="filter-overlay">
    <div class="filter-overlay__container">
        <div class="filter-overlay__content">
            <p><strong>New</strong> <br>View by recently added topics</p>
            <p><strong>Top All-Time</strong> <br>View by highly discussed topics</p>
            <p><strong>Following</strong> <br>View by topics you follow</p>
            <p><strong>Archived - Read Only</strong> <br>Archived topics <br>(due to over discussion)</p>
        </div>
        <a href="#" class="filter-overlay__close">OK</a>
    </div>
</div>


<?php
    $view_filter = '';
    $view_selected = 'top';
    if(isset($_GET['view'])) {
        $view_selected = $_GET['view'];
        $view_filter = '&view=' . $_GET['view'];
    }

    $category_selected = '';
    $category_filter = '';
    if(isset($_GET['category'])) {
        $category_selected = $_GET['category'];
        $category_filter = 'category=' . $_GET['category'];
    }

    $category_filter_type = '';
    if(isset($_GET['category_type'])) {
        $category_filter_type = $_GET['category_type'];
    }
?>

<!-- List primary filters -->
<div class="filters filters-panel filters-panel--filters">
    <a href="#" class="filters__help-btn">?</a>
    <div class="filters__inner">
        <div class="filters__heading">View</div>
        <div class="checkbox-grid">
            <div class="container container--no-vertical-padding container--no-right-padding">
                <div class="input__checkbox checkbox-grid__input">
                    <a href="<?php echo URL_BASE; ?>community?<?php echo ($view_selected != 'new' ? 'view=new&' : ''); ?><?php echo $category_filter; ?>" class="filters__btn checkbox-grid__label <?php echo ($view_selected == 'new' ? 'filters__btn--selected' : ''); ?>">
                        New <span class="tick"></span>
                    </a>
                </div>
                <div class="input__checkbox checkbox-grid__input">
                    <a href="<?php echo URL_BASE; ?>community?<?php echo ($view_selected != 'top' ? 'view=top&' : ''); ?><?php echo $category_filter; ?>" class="filters__btn checkbox-grid__label <?php echo ($view_selected == 'top' ? 'filters__btn--selected' : ''); ?>">
                        Top all-time <span class="tick"></span>
                    </a>
                </div>
                <?php if(App::loggedIn() && $this->show_profile): ?>
                    <div class="input__checkbox checkbox-grid__input">
                        <a href="<?php echo URL_BASE; ?>community?<?php echo ($view_selected != 'subscribed' ? 'view=subscribed&' : ''); ?><?php echo $category_filter; ?>" class="filters__btn checkbox-grid__label <?php echo ($view_selected == 'subscribed' ? 'filters__btn--selected' : ''); ?>">
                            Following <span class="tick"></span>
                        </a>
                    </div>
                <?php endif; ?>
                <div class="input__checkbox checkbox-grid__input">
                    <a href="<?php echo URL_BASE; ?>community?<?php echo ($view_selected != 'archived' ? 'view=archived&' : ''); ?><?php echo $category_filter; ?>" class="filters__btn checkbox-grid__label <?php echo ($view_selected == 'archived' ? 'filters__btn--selected' : ''); ?>">
                        Archived <span class="tick"></span>
                    </a>
                </div>
            </div>
        </div>

        <div class="filters__heading">Filter By Category</div>
        <div class="checkbox-grid">
            <div class="container container--no-vertical-padding container--no-right-padding">
                <?php if($category_selected) : ?>
                    <div class="input__checkbox checkbox-grid__input">
                        <a href="#" class="filters__btn filters__btn__type filters__btn__type--show-categories checkbox-grid__label"><?php echo ucfirst($category_filter_type) . ' (' . TopicCategoryModel::getNameBySlug($category_selected) . ')'; ?></a>
                    </div>
                <?php else: ?>
                    <div class="input__checkbox checkbox-grid__input">
                        <a href="#" class="filters__btn filters__btn__type--show-categories checkbox-grid__label">Select a Category</a>
                    </div>
                <?php endif; ?>
            </div>
        </div>
        
        <a href="<?php echo URL_BASE; ?>community" class="filters__clear">Clear Filters</a>
        <div class="clearfix"></div>
        
    </div>
</div>

<!-- Contains listing of each category value -->
<div class="filters filters-panel filters-panel--categories">
    <div class="filters-panel__backbutton">
        <a href="#" class="filters-panel--categories-back">Back</a>
    </div>
    <div class="filters__inner filters__inner--no-bottom-padding"> 
        <div class="filters__heading">Select a Category</div>

        <div class="checkbox-grid">
            <div class="container container--no-vertical-padding container--no-right-padding">
                <div class="checkbox-grid__input">
                    <a href="#" data-type="health" class="filters__btn checkbox-grid__label filters__btn__type <?php echo ($this->selected_type == 'health' ? 'filters__btn__type--selected' : ''); ?>">Health<span class="tick"></span></a>
                </div>
                <div class="checkbox-grid__input">
                    <a href="#" data-type="identity" class="filters__btn checkbox-grid__label filters__btn__type <?php echo ($this->selected_type == 'identity' ? 'filters__btn__type--selected' : ''); ?>">Identity<span class="tick"></span></a>
                </div>
                <div class="checkbox-grid__input">
                    <a href="#" data-type="age" class="filters__btn checkbox-grid__label filters__btn__type <?php echo ($this->selected_type == 'age' ? 'filters__btn__type--selected' : ''); ?>">Age<span class="tick"></span></a>
                </div>
            </div>
        </div>
        
        <div class="filters__heading filters__heading--category">Select {Insert Category Here}</div>
        <div class="checkbox-grid checkbox-grid--no-bottom-margin">
            <div class="container container--no-vertical-padding container--no-right-padding">
                <?php foreach(array('age', 'health', 'identity') as $type) : ?>
                    <div class="filters__orientation filters__orientation--<?php echo $type; ?> <?php echo ($this->selected_type != $type ? 'filters__orientation--hide' : ''); ?>">
                        <?php foreach($this->categories[$type] as $category) : ?>
                        <div class="checkbox-grid__input">
                            <a class="filters__btn checkbox-grid__label <?php echo ($category->getSlug() == $this->selected_category ? 'filters__btn--selected' : ''); ?>" href="<?php echo URL_BASE; ?>community?category=<?php echo $category->getSlug(); ?><?php echo $view_filter; ?>&category_type=<?php echo $type; ?>"><?php echo $category->getName(); ?> <span class="tick"></span></a>
                        </div>
                        <?php endforeach; ?>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
    </div>
</div>

<?php endif; ?>