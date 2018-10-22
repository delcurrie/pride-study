<?php 

/**
 * Represent an individual comment and all of the 
 * parameters surrounding that.
 */
class CommentModule extends BaseModule
{
    public $view = 'Comment.php';

    public $user = false,
           $comment = false,
           $is_reply = false,
           $is_users = false,
           $can_vote = false,
           $can_reply = false,
           $can_flag = false,
           $user_flagged = false;

    /**
     * Process the module
     * 
     * @return void
     */
    public function process()
    {
        if (!$this->user) {
            $this->user = App::getLoggedInUser();
        }

        if (!$this->can_vote && $this->comment) {
            $this->can_vote = App::loggedIn() && $this->user->canVote($this->comment);
        }

        if (!$this->can_flag && $this->comment) {
            $this->can_flag = App::loggedIn() && $this->user->canFlag($this->comment);
        }

        if (!$this->is_reply && !$this->can_reply && $this->comment) {
            $this->can_reply = App::loggedIn() && $this->user->canReply($this->comment);
        }

        if ($this->comment && $this->user) {
            $this->is_users = App::loggedIn() && $this->comment->getUserId() == $this->user->getId();
        }

        if ($this->comment && $this->user) {
            $this->user_flagged = $this->comment->userFlagged($this->user);
        }

        $this->render();
    }
}
