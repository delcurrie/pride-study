<?php 

class TopicFlagModel extends BaseModel {

	protected $id = 0;
	protected $topic_id = 0;
	protected $user_id = 0;

	protected static $table_name = 'topic_flags';

    /**
     * Gets the value of id.
     *
     * @return mixed
     */
    public function getId()
    {
        return (int)$this->id;
    }

    /**
     * Gets the value of topic_id.
     *
     * @return mixed
     */
    public function getTopicId()
    {
        return (int)$this->topic_id;
    }

    /**
     * Gets the value of user_id.
     *
     * @return mixed
     */
    public function getUserId()
    {
        return (int)$this->user_id;
    }

    /**
     * Get a flag by topic and user
     * 
     * @param  TopicModel $topic
     * @param  UserModel  $user
     * @return TopicFlagModel
     */
    public static function getTopicFlagByUser(TopicModel $topic, UserModel $user)
    {
    	return current(self::find(array('topic_id = :tid', 'user_id = :uid'), array(
    		'uid' => $user->getId(),
    		'tid' => $topic->getId()
    	)));
    }
}