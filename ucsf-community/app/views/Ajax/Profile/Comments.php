<?php foreach($comments as $comment) : ?>
    <li class="settings-panel__activity__list__item">
        <a href="<?php echo $comment->getTopic()->getUrl(); ?>?back_profile=true">
            <h2 class="settings-panel__activity__list__item__title"><?php echo $comment->getMessage(); ?></h2>
            <span class="settings-panel__activity__list__item__meta"><?php echo date('m/d/y', $comment->getCreatedAt()); ?></span>
        </a>
    </li>
<?php endforeach; ?>