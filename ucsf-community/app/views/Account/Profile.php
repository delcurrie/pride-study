<?php $this->loadModule('Header'); define('PROFILE_SHOW_MORE', 'Show More'); ?>

<div class="settings-panel">

    <?php $this->loadModule('Navigation'); ?>

    <div class="settings-panel__header">
        <div class="settings-panel__profilepic"><span class="settings-panel__profilepic__initial"><?php echo $user->getInitial(); ?></span></div>
        <div class="settings-panel__name"><?php echo $details->getScreenName(); ?></div>
        <a href="<?php echo URL_BASE.'account/edit'; ?>" class="settings-panel__editprofile">Settings</a>
    </div>

    <div class="settings-panel__statistics">
        <a><span><?php echo $user->getTopicCount(); ?></span>
            POSTS</a>

        <a><span><?php echo $user->getCommentCount(); ?></span>
            COMMENTS</a>

        <a><span><?php echo $user->getUpvoteCount(); ?></span>
            upvotes</a>

        <a><span><?php echo $user->getDownvoteCount(); ?></span>
            downvotes</a>
    </div>

    <div class="clearfix"></div>

    <div class="settings-panel__activity">
        <div class="settings-panel__activity__inner__wrapper">
            <div class="settings-panel__activity__inner__container">
                <div class="settings-panel__activity__inner settings-panel__activity__inner--one settings-panel__activity__inner--show">
                    <a href="#" data-list="posts" class="settings-panel__activity__item settings-panel__activity__item--active">Posts</a>
                    <a href="#" data-list="comments" class="settings-panel__activity__item">Comments</a>
                </div>
                <div class="settings-panel__activity__inner settings-panel__activity__inner--two">
                    <a href="#" data-list="upvoted" class="settings-panel__activity__item">Upvoted</a>
                    <a href="#" data-list="downvoted" class="settings-panel__activity__item">Downvoted</a>
                </div>
            </div>
            <div class="settings-panel__activity__item__scroller settings-panel__activity__item__scroller--right"></div>
        </div>

        <ul class="settings-panel__activity__list settings-panel__activity__list--posts settings-panel__activity__list--show">
            <?php foreach($posts as $post) : ?>
                <li class="settings-panel__activity__list__item">
                    <a href="<?php echo $post->getUrl(); ?>?back_profile=true">
                        <h2 class="settings-panel__activity__list__item__title"><?php echo $post->getTitle(); ?></h2>
                        <span class="settings-panel__activity__list__item__meta"><?php echo date('m/d/y', $post->getCreatedAt()); ?></span>
                    </a>
                </li>
            <?php endforeach; ?>

            <?php if ($user->getTopicCount() > 3): ?>
                <li class="settings-panel__activity__show-more"><a href="<?php echo URL_BASE; ?>account/profile/topics" data-load="next" data-offset="<?php echo count($posts) ?>" data-limit="5"><?php echo PROFILE_SHOW_MORE; ?></a></li>
            <?php endif; ?>
        </ul>

        <ul class="settings-panel__activity__list settings-panel__activity__list--comments">
            <?php foreach($comments as $comment) : ?>
                <li class="settings-panel__activity__list__item">
                    <a href="<?php echo $comment->getTopic()->getUrl(); ?>?back_profile=true">
                        <h2 class="settings-panel__activity__list__item__title"><?php echo $comment->getMessage(); ?></h2>
                        <span class="settings-panel__activity__list__item__meta"><?php echo date('m/d/y', $comment->getCreatedAt()); ?></span>
                    </a>
                </li>
            <?php endforeach; ?>

            <?php if ($user->getCommentCount() > 3): ?>
                <li class="settings-panel__activity__show-more"><a href="<?php echo URL_BASE; ?>account/profile/comments" data-load="next" data-offset="<?php echo count($comments) ?>" data-limit="5"><?php echo PROFILE_SHOW_MORE; ?></a></li>
            <?php endif; ?>
        </ul>

        <ul class="settings-panel__activity__list settings-panel__activity__list--upvoted">
            <?php foreach($upvoted as $vote) : ?>
                <li class="settings-panel__activity__list__item">
                    <a href="<?php echo $vote->getVoteUrl(); ?>?back_profile=true">
                        <h2 class="settings-panel__activity__list__item__title"><?php echo $vote->getVoteText(); ?></h2>
                        <span class="settings-panel__activity__list__item__meta"><?php echo $vote->getVoteDate(); ?></span>
                    </a>
                </li>
            <?php endforeach; ?>

            <?php if ($user->getUpvoteCount() > 3): ?>
                <li class="settings-panel__activity__show-more"><a href="<?php echo URL_BASE; ?>account/profile/upvoted" data-load="next" data-offset="<?php echo count($upvoted) ?>" data-limit="5"><?php echo PROFILE_SHOW_MORE; ?></a></li>
            <?php endif; ?>
        </ul>

        <ul class="settings-panel__activity__list settings-panel__activity__list--downvoted">
            <?php foreach($downvoted as $vote) : ?>
                <li class="settings-panel__activity__list__item">
                    <a href="<?php echo $vote->getVoteUrl(); ?>?back_profile=true">
                        <h2 class="settings-panel__activity__list__item__title"><?php echo $vote->getVoteText(); ?></h2>
                        <span class="settings-panel__activity__list__item__meta"><?php echo $vote->getVoteDate(); ?></span>
                    </a>
                </li>
            <?php endforeach; ?>

            <?php if ($user->getDownvoteCount() > 3): ?>
                <li class="settings-panel__activity__show-more"><a href="<?php echo URL_BASE; ?>account/profile/downvoted" data-load="next" data-offset="<?php echo count($downvoted) ?>" data-limit="5"><?php echo PROFILE_SHOW_MORE; ?></a></li>
            <?php endif; ?>
        </ul>

    </div>

</div>

<?php $this->loadModule('Footer'); ?>