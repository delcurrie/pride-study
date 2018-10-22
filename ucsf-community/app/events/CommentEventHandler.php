<?php 
    
/**
 * Represent the event handler for comments
 */
class CommentEventHandler extends EventHandler
{

    /**
     * Handle the case when someone has replied
     * to a users comment.
     * 
     * @param  TopicModel $topic
     * @param  CommentModel $user_comment
     * @param  CommentModel $reply_comment
     * @return mixed     
     */
    public static function replied(TopicModel $topic, CommentModel $user_comment, CommentModel $reply_comment)
    {
        if ($user_comment->isUserNotifiedByReplies()) {
            $user = $user_comment->getUser();
            $reply_comment_user = $reply_comment->getUser();

            if ($user->getId() == $reply_comment_user->getId()) {
                return false;
            }

            if (Notification::isAllowedEmailAddress($user->getEmailAddress())) {
            	
            	$recipients = array(
	                new Recipient($user->getDetails()->getScreenName(), $user->getEmailAddress())
	            );

	            $notification = Notification::getInstance();
	            $notification->build($recipients, 'Someone replied to your comment.', 'comment-reply', array(
	                'topic' => $topic->getTitle(),
	                'user_comment_message' => $user_comment->getMessage(),
	                'user_comment_url' => $topic->getUrl(),
	                'comment_message' => $reply_comment->getMessage(),
	                'comment_user' => $reply_comment_user->getDetails()->getScreenName()
	            ));

            	$notification->send();
            }
        }
    }

    /**
     * Handle the event when a comment is flagged
     * 
     * @param  CommentModel $comment
     * @return mixed           
     */
    public static function flagged(CommentModel $comment)
    {
        // Let's just double check
        if ($comment->isFlagged()) {
            $admins = AdminUserModel::getNotifiable();
            $recipients = array();

            $topic = $comment->getTopic();
            
            foreach ($admins as $admin) {
                $recipients[] = new Recipient($admin->getUsername(), $admin->getEmail());
            }

            $notification = Notification::getInstance();
            $notification->build($recipients, 'Someone flagged a comment.', 'comment-flagged', array(
                'comment'   => $comment->getMessage(),
                'url' => HTTP_SERVER.URL_BASE.'cmsadmin/topics_detail.php?id=' . $topic->getId() . '#comment' . $comment->getId()
            ));

            $notification->send();
        }
    }
}
