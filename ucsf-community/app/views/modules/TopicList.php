<?php foreach($this->topics as $topic) : ?>
    <div class="post <?php if($topic->isFeatured()) : ?>post--highlight<?php endif; ?>" data-can-vote="<?php echo (App::loggedIn() && App::getLoggedInUser()->canVote($topic) ? 'true' : 'false'); ?>">
        <div class="post__inner">
            <a href="<?php echo ($this->single_topic_view ? '#' : $topic->getUrl()) ;?>" class="post__title <?php echo ($this->single_topic_view ? 'post__title--inactive' : '') ;?>"><?php echo $topic->getTitle(); ?></a>
            
            <?php if($this->single_topic_view) : $categories = $topic->getCategories(); ?>
                <?php if(!empty($categories)) : ?>
                    <div class="post__tags">
                        Tags:
                        <?php $count = count($categories); $i = 0; foreach($categories as $category) : ?>
                            <a href="<?php echo URL_BASE; ?>community?category=<?php echo $category->getSlug(); ?>&category_type=<?php echo $category->getType(); ?>" class="post__tags__tag"><?php echo $category->getName(); ?></a><?php echo ($i == $count - 1 ? '' : ', '); ?>
                        <?php $i++; endforeach; ?>
                    </div>
                <?php endif; ?>
                <div class="post__author">
                    <span><?php echo $topic->getUserName(); ?></span> <?php echo $topic->getTimeAgo(); ?>
                </div>
            <?php endif; ?>
            <div class="postnav">
                <a href="#" class="postnav__btn postnav__btn--topic postnav__btn--up <?php echo ($topic->userUpvoted() ? 'postnav__btn--active' : ''); ?> topic-upvote-handle" data-id="<?php echo $topic->getId(); ?>" data-value="<?php echo $topic->getUpvotes(); ?>"><span></span><?php echo $topic->getUpvotes(); ?></a>
                <a href="#" class="postnav__btn postnav__btn--topic postnav__btn--dn <?php echo ($topic->userDownvoted() ? 'postnav__btn--active' : ''); ?> topic-downvote-handle" data-id="<?php echo $topic->getId(); ?>" data-value="<?php echo $topic->getDownvotes(); ?>"><span></span><?php echo $topic->getDownvotes(); ?></a>
                <a href="<?php echo $topic->getUrl() ;?>" class="postnav__btn postnav__btn--topic postnav__btn--comment"><span></span><?php echo $topic->getCommentCount(); ?></a>
                <a href="#" class="postnav__btn postnav__btn--ellipses"><span></span></a>
            </div>
        </div>
        <div class="postbuttons">
            <div class="postbuttons__container">
                <a href="#" class="postbuttons__btn postbuttons__btn--sub subscribe-handle" data-id="<?php echo $topic->getId(); ?>" data-can-subscribe="<?php echo App::getLoggedInUser()->canSubscribe($topic) && !$topic->isArchived() ? 'true' : 'false'; ?>">
                    <?php if(!$topic->userSubscribed()): ?> Follow conversation <?php else: ?> Unfollow <?php endif; ?>
                </a>
                <a href="#" class="postbuttons__btn postbuttons__btn--flag flag-handle" data-id="<?php echo $topic->getId(); ?>" <?php echo (!$topic->userFlagged() ? 'data-enabled="true"': 'data-user-flagged="true"'); ?> data-can-flag="<?php echo App::getLoggedInUser()->canFlag($topic) && !$topic->isArchived() ? 'true' : 'false'; ?>">
                    <?php if(!$topic->userFlagged()): ?> Flag as inappropriate <?php else: ?> Already Flagged <?php endif; ?>
                </a>
                <a href="#" class="postbuttons__btn postbuttons__btn--close"></a>
            </div>
        </div>
    </div>

    <?php if($this->single_topic_view) : ?>
        <div class="post__description">
            <div class="post__description__inner">
                <?php echo $topic->getDescription(); ?>
            </div>
        </div>
    <?php endif; ?>
<?php endforeach; ?>