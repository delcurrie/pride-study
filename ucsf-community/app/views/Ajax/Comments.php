<?php foreach($comments as $comment) : // Top-level comments ?>  
        
        <?php $children = $comment->getChildren(); ?>
        <?php $this->setModuleVar('Comment', 'is_reply', false)->setModuleVar('Comment', 'comment', $comment)->loadModule('Comment'); ?>

        <?php foreach($children as $child_comment) : // 1st Level replies ?>
            <?php $this->setModuleVar('Comment', 'is_reply', true)->setModuleVar('Comment', 'comment', $child_comment)->loadModule('Comment'); ?>
        <?php endforeach; ?>

<?php endforeach; ?>