<?php 

/**
 * Representation of a sub on a topic from a user
 */
class TopicSubscriptionModel extends BaseModel {

	protected $id = 0;
	protected $topic_id = 0;
	protected $user_id = 0;

	protected static $table_name = 'topic_subscriptions';

	/**
	 * Check whether or not a user is subscribed to a
	 * topic
	 * 
	 * @param  UserModel  $user
	 * @param  TopicModel $topic
	 * @return bool
	 */
	public static function getSubscribedToTopic(UserModel $user, TopicModel $topic)
	{
		return current(self::find(array('user_id = :uid', 'topic_id = :tid'), array(
			':uid' => $user->getId(),
			':tid' => $topic->getId(),
		), 'limit 1'));
	}

	/**
	 * Get all topics for a user
	 * 
	 * @param UserModel user
	 * @return Array<TopicModel>
	 */
	public static function getTopicsByUser(UserModel $user)
	{
		$return_topics = array();
		$topics = self::findByUser($user);
		foreach ($topics as $topic) {
			$return_topics[] = TopicModel::findById($topic->getTopicId());
		}
		return $return_topics;
	}

	/**
	 * Get all users by topic 
	 *
	 * @param  TopicModel $topic
	 * @return Array<UserModel>
	 */
	public static function getUsersByTopic(TopicModel $topic)
	{
		$return_users = array();
		$users = self::findByTopic($topic);
		foreach ($users as $user) {
			$return_users[] = UserModel::findById($user->getUserId());
		}
		return $return_users;
	}

	/**
	 * Get subscriber count by topic
	 * 
	 * @param  TopicModel $topic
	 * @return int
	 */
	public static function getSubscriberCountByTopic(TopicModel $topic)
	{
		return count(self::findByTopic($topic));
	}

	/**
	 * Get the total number of subscribed topics by user
	 * 
	 * @param UserModel user
	 * @return int
	 */
	public static function getSubscribedCountByUser(UserModel $user)
	{
		return count(self::findByUser($user));
	}

	/**
	 * Find these relationships by user
	 * 
	 * @param  UserModel $user
	 * @return Array<TopicSubscriptionModel>
	 */
	public static function findByUser(UserModel $user, $extra = '')
	{
		return self::find(array('user_id = :id'), array('id' => $user->getId()), $extra);
	}

	/**
	 * Find these relationships by topic
	 * 
	 * @param  TopicModel $topic
	 * @return Array<TopicSubscriptionModel>
	 */
	public static function findByTopic(TopicModel $topic)
	{
		return self::find(array('topic_id = :id'), array('id' => $topic->getId()));
	}

	/**
	 * Get the relationship id
	 * 
	 * @return int
	 */
	public function getId()
	{
		return (int)$this->id;
	}

    /**
     * Gets the value of topic_id.
     *
     * @return (int)
     */
    public function getTopicId()
    {
        return (int)$this->topic_id;
    }

    /**
     * Gets the value of user_id.
     *
     * @return (int)
     */
    public function getUserId()
    {
        return (int)$this->user_id;
    }

    /**
     * Get the topic associated to this sub
     * 
     * @return TopicModel
     */
    public function getTopic()
    {
    	return TopicModel::findById($this->getTopicId());
    }
}