<?php $this->loadModule('Header'); ?>

<div class="showtopic main postcontainer">

<?php $this->loadModule('Navigation'); ?>
    
    <div class="topic-container">
        <?php $this->loadModule('TopicList'); ?>
    </div>
    
    <?php if(!$topic->isArchived() && App::loggedIn() && App::getLoggedInUser()->hasScreenName() && App::getLoggedInUser()->canPostComments()): ?> 
        <div class="reply">
            <form class="topic-reply-form">
                <input type="hidden" name="topic_id" value="<?php echo $topic->getId(); ?>">
                <textarea name="message" placeholder="Post a comment here..."></textarea>
                <input type="submit" name="submit" class="button button--orange-fill" value="Post Comment">
            </form>
        </div>
    <?php endif; ?>

    <div class="comments" id="comments"></div>
    <a class="load-more-comments" data-topic="<?php echo $topic->getId(); ?>" data-offset="0" data-amount="10">
        Load More Comments
    </a>

</div>

<?php $this->loadModule('Footer'); ?>