<?php 

/**
 * Represent rows in the table which
 * keeps track of users votes.
 */
class UserVoteModel extends BaseModel
{
	protected $id = 0;
	protected $user_id = 0;
	protected $topic_voter_id = 0;
	protected $comment_voter_id = 0;
	protected $is_topic_vote = 1;
	protected $upvote = 1;
	protected $created_at = 0;
	protected $updated_at = 0;

	protected static $table_name = 'users_votes';

    /**
     * Gets the value of id.
     *
     * @return mixed
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Gets the value of user_id.
     *
     * @return mixed
     */
    public function getUserId()
    {
        return $this->user_id;
    }

    /**
     * Gets the value of topic_voter_id.
     *
     * @return mixed
     */
    public function getTopicVoterId()
    {
        return $this->topic_voter_id;
    }

    /**
     * Gets the value of comment_voter_id.
     *
     * @return mixed
     */
    public function getCommentVoterId()
    {
        return $this->comment_voter_id;
    }

    /**
     * Gets the value of is_topic_vote.
     *
     * @return mixed
     */
    public function getIsTopicVote()
    {
        return $this->is_topic_vote;
    }

    /**
     * Gets the value of upvote.
     *
     * @return mixed
     */
    public function getUpvote()
    {
        return $this->upvote;
    }

    /**
     * Gets the value of created_at.
     *
     * @return mixed
     */
    public function getCreatedAt()
    {
        return $this->created_at;
    }

    /**
     * Gets the value of updated_at.
     *
     * @return mixed
     */
    public function getUpdatedAt()
    {
        return $this->updated_at;
    }

    /**
     * Get the correct data row for this
     * vote.
     * 
     * @return VoteInterface (CommentVoteModel / TopicVoteModel)
     */
    public function getRow()
    {
		return $this->getIsTopicVote() ? TopicVoteModel::findById($this->getTopicVoterId()) : CommentVoteModel::findById($this->getCommentVoterId());
    }

    /**
     * Get the count of upvotes for this user.
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function getCountUpvotesByUser(UserModel $user)
    {
    	return self::count(array('user_id = :id', 'upvote = 1'), array('id' => $user->getId()));
    }

    /**
     * Get the count of Downvotes for this user.
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function getCountDownvotesByUser(UserModel $user)
    {
    	return self::count(array('user_id = :id', 'upvote = 0'), array('id' => $user->getId()));
    }

    /**
     * Get the upvotes for this user.
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function getUpvotesByUser(UserModel $user, $extra = 'order by id desc limit 3')
    {
    	return self::find(array('user_id = :id', 'upvote = 1'), array('id' => $user->getId()), $extra);
    }

    /**
     * Get the Downvotes for this user.
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function getDownvotesByUser(UserModel $user, $extra = 'order by id desc limit 3')
    {
    	return self::find(array('user_id = :id', 'upvote = 0'), array('id' => $user->getId()), $extra);
    }

    /**
     * Get the count of upvotes for this user.
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function countUpvotesByUser(UserModel $user)
    {
        return self::count(array('user_id = :id', 'upvote = 1'), array('id' => $user->getId()));
    }

    /**
     * Get the count of Downvotes for this user.
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function countDownvotesByUser(UserModel $user)
    {
        return self::count(array('user_id = :id', 'upvote = 0'), array('id' => $user->getId()));
    }

    /**
     * Delete a row by the comment vote id
     * 
     * @param  int $id
     * @return void    
     */
    public static function deleteByCommentVoteId($id)
    {
        $table = self::getTableName();
        $db = Database::getInstance();
        $db->query('delete from ' . $table . ' where comment_voter_id = ' . (int)$id);
    }

    /**
     * Delete a row by the topic vote id
     * 
     * @param  int $id
     * @return void    
     */
    public static function deleteByTopicVoteId($id)
    {
        $table = self::getTableName();
        $db = Database::getInstance();
        $db->query('delete from ' . $table . ' where topic_voter_id = ' . (int)$id);
    }

    /**
     * Update a users vote by the comment voter id
     * 
     * @param  int $id
     * @param  array  $data
     * @return UserVoteModel       
     */
    public static function updateByCommentVoteId($id, $data = array())
    {
        $vote = current(self::find(array('comment_voter_id = :id'), array('id' => $id), 'limit 1'));
        return self::update($vote->getId(), $data);
    }

    /**
     * Update a users vote by the Topic voter id
     * 
     * @param  int $id
     * @param  array  $data
     * @return UserVoteModel       
     */
    public static function updateByTopicVoteId($id, $data = array())
    {
        $vote = current(self::find(array('topic_voter_id = :id'), array('id' => $id), 'limit 1'));
        return self::update($vote->getId(), $data);
    }
}