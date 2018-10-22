<?php foreach($upvoted as $vote) : ?>
    <li class="settings-panel__activity__list__item">
        <a href="<?php echo $vote->getVoteUrl(); ?>?back_profile=true">
            <h2 class="settings-panel__activity__list__item__title"><?php echo $vote->getVoteText(); ?></h2>
            <span class="settings-panel__activity__list__item__meta"><?php echo $vote->getVoteDate(); ?></span>
        </a>
    </li>
<?php endforeach; ?>