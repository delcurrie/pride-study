<?php foreach($posts as $post): ?>
<li class="settings-panel__activity__list__item">
    <a href="<?php echo $post->getUrl(); ?>?back_profile=true">
        <h2 class="settings-panel__activity__list__item__title"><?php echo $post->getTitle(); ?></h2>
        <span class="settings-panel__activity__list__item__meta"><?php echo date('m/d/y', $post->getCreatedAt()); ?></span>
    </a>
</li>
<?php endforeach ?>