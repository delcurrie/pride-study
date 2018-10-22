<?php 
	
/**
 * Represent the event handler for topics
 */
class TopicEventHandler extends EventHandler {

	/**
	 * Handle the update of a topic
	 * 
	 * @param  TopicModel $topic
	 * @return mixed     
	 */
	public static function updated(TopicModel $topic)
	{	
		$topic->calculateScore(true);
	}

	/**
	 * Handle the event of a new topic
	 * being posted.
	 * 
	 * @param  TopicModel $topic
	 * @return mixed      
	 */
	public static function posted(TopicModel $topic)
	{
		$recipients = array();
		$users = UserModel::findNotifiedByNewPosts();
		
		foreach($users as $user) {
			if($user->getId() == $topic->getUser()->getId() || !Notification::isAllowedEmailAddress($user->getEmailAddress())) continue;
			$recipients[] = new Recipient($user->getDetails()->getScreenName(), $user->getEmailAddress());
		}

		$notification = Notification::getInstance();
		$notification->build($recipients, 'Someone posted a new topic.', 'new-post', array(
			'topic' => $topic->getTitle(),
			'topic_message' => $topic->getDescription()
		));

		$notification->send();
	}

	/**
	 * Handle the case when someone has replied
	 * to a users topic.
	 * 
	 * @param  TopicModel $topic
	 * @param  CommentModel $comment
	 * @return mixed     
	 */
	public static function replied(TopicModel $topic, CommentModel $comment)
	{
		if($topic->isUserNotifiedByReplies()) {
			$user = $topic->getUser();
			$comment_user = $comment->getUser();

			if($user->getId() != $comment_user->getId()) {
				if (Notification::isAllowedEmailAddress($user->getEmailAddress())) {
					$recipients = array(
						new Recipient($user->getDetails()->getScreenName(), $user->getEmailAddress())
					);

					$notification = Notification::getInstance();
					$notification->build($recipients, 'Someone has replied to your topic.', 'post-reply', array(
						'topic' => $topic->getTitle(),
						'comment_message' => $comment->getMessage(),
						'comment_user' => $comment_user->getDetails()->getScreenName()
					));

					$notification->send();
				}
			}
			
			$subscribers = $topic->getSubscribers();

			$sub_recipients = array();
			foreach($subscribers as $subscriber) {

				if ($user->getId() == $subscriber->getId()) continue;
				if (!Notification::isAllowedEmailAddress($subscriber->getEmailAddress())) continue;

				if ($subscriber->getDetails()->getScreenName() != $comment_user->getDetails()->getScreenName()) {				
					$sub_recipients[] = new Recipient($subscriber->getDetails()->getScreenName(), $subscriber->getEmailAddress());
				}
			}

			$sub_notification = Notification::getInstance();
			$sub_notification->build($sub_recipients, "Someone has replied to a topic you're subscribed to.", 'post-subscribed', array(
				'topic' => $topic->getTitle(),
				'comment_message' => $comment->getMessage(),
				'comment_user' => $comment_user->getDetails()->getScreenName()
			));

			$sub_notification->send();
		}
	}

	/**
	 * Handle the event when a topic is flagged
	 * 
	 * @param  TopicModel $topic
	 * @return mixed           
	 */
	public static function flagged(TopicModel $topic)
	{
		// Let's just double check
		if ($topic->isFlagged()) {
			
			$admins = AdminUserModel::getNotifiable();
			$recipients = array();
			
			foreach($admins as $admin) {
				$recipients[] = new Recipient($admin->getUsername(), $admin->getEmail());
			}

			$notification = Notification::getInstance();
			$notification->build($recipients, 'Someone flagged a topic.', 'topic-flagged', array(
				'topic' 	=> $topic->getTitle(),
				'topic_url' => HTTP_SERVER.URL_BASE.'cmsadmin/topics_detail.php?id=' . $topic->getId()
			));

			$notification->send();
		}
	}
}