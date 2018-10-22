<?php $this->loadModule('Header'); ?>

<div class="main postcontainer">

<?php $this->loadModule('Navigation'); ?>     
    
    <?php if(empty($topics)) : ?>
        <div class="no-topics">
            <?php if(isset($_GET['term']) && !empty($_GET['term'])) : ?>
                <p class="no-topics__message">No results for search term "<em class="no-topics__term"><?php echo $_GET['term']; ?></em>"</p>
            <?php else : ?>
                <p class="no-topics__message">No results</p>
            <?php endif; ?>
            <a class="no-topics__back" href="<?php echo URL_BASE; ?>community">Back to Community</a>
        </div>
    <?php else : ?>
        <?php if(App::loggedIn() && App::getLoggedInUser()->canPostTopics()) : ?>
            <div class="postheader">
                <div class="container">
                    <a href="<?php echo URL_BASE;?>community/topics/create" class="newpost"></a>
                    <div class="postheader__title">Post a topic you would like researchers to study about the LGBTQ community</div>
                </div>
            </div>
        <?php endif; ?>
        <div class="topic-container"></div>
        <a class="load-more-topics" data-offset="0" data-amount="5" data-view="<?php echo (isset($_GET['view']) ? $_GET['view'] : 'false'); ?>" <?php echo (isset($_GET['term']) ? 'data-term="' . $_GET['term'] . '"' : ''); ?> data-category="<?php echo (isset($_GET['category']) ? $_GET['category'] : 'false'); ?>">
        	Load More Posts
        </a>
    <?php endif; ?>
    
</div>

<?php $this->loadModule('Footer'); ?>