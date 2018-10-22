<div class="comments__post <?php echo($this->is_reply ? 'comments--reply1' : 'comment-handle'); ?>" 
     data-id="<?php echo $this->comment->getId(); ?>" 
     data-can-vote="<?php echo($this->can_vote ? 'true' : 'false'); ?>" 
     data-can-flag="<?php echo($this->can_flag ? 'true' : 'false'); ?>" 
     data-is-users="<?php echo($this->is_users ? 'true' : 'false'); ?>"
     data-can-reply="<?php echo($this->can_reply ? 'true' : 'false'); ?>"
     data-user-flagged="<?php echo($this->user_flagged ? 'true' : 'false'); ?>">

    <div class="comments__profile"><span class="comments__profile__initial"><?php echo $this->comment->getUser()->getInitial(); ?></span></div>
    <p><?php echo $this->comment->getMessage(); ?></p>
    <div class="comments__nav <?php echo(!$this->comment->userCanInteract() ? 'comments__nav--disabled' : ''); ?>">
        <a href="#" class="postnav__btn postnav__btn--cmmt postnav__btn--up <?php echo $this->comment->getUpvotes() > 0 ? 'postnav__btn--active' : ''; ?>"><span></span><?php echo $this->comment->getUpvotes(); ?></a>
        <a href="#" class="postnav__btn postnav__btn--cmmt postnav__btn--dn <?php echo $this->comment->getDownvotes() ? 'postnav__btn--active' : ''; ?>"><span></span><?php echo $this->comment->getDownvotes(); ?></a>
        
        <?php if (!$this->is_reply) : ?>
            <a href="#" class="postnav__btn postnav__btn--cmmt postnav__btn--comment comment-handle" data-id="<?php echo $this->comment->getId(); ?>"><span></span><?php echo count($children); ?></a>
        <?php endif; ?>

        <a href="#" class="postnav__btn postnav__btn--cmmt postnav__btn--flag <?php echo($this->comment->userFlagged() ? 'postnav__btn--active' : ''); ?>"><span></span></a>
    </div>

</div>