<div class="checkbox-grid">
    <div class="container container--no-vertical-padding container--no-right-padding">
        <div class="input__checkbox checkbox-grid__input">
            <input type="checkbox" name="new_posts" id="new_posts" <?php echo ($this->details->getNewPosts() ? 'checked' : ''); ?>>
            <label for="new_posts" class="checkbox-grid__label">New Posts <span></span></label>
        </div>
        <div class="input__checkbox checkbox-grid__input">
            <input type="checkbox" name="replies_to_comments" id="comments_on_my_posts" <?php echo ($this->details->getRepliesToComments() ? 'checked' : ''); ?>>
            <label for="comments_on_my_posts" class="checkbox-grid__label">Replies to My Comments<span></span></label>
        </div>
        <div class="input__checkbox checkbox-grid__input">
            <input type="checkbox" name="replies_to_posts" id="replies_to_posts" <?php echo ($this->details->getRepliesToPosts() ? 'checked' : ''); ?>>
            <label for="replies_to_posts" class="checkbox-grid__label">Comments on My Posts <span></span></label>
        </div>
    </div>
</div>