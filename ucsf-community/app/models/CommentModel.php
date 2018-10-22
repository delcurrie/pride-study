<?php 

class CommentModel extends BaseModel implements FlaggableModel, VotableModel {

	protected $id = 0;
	protected $user_id = 0;
    protected $topic_id = 0;
	protected $parent_comment_id = 0;
	protected $message = '';
    protected $archived = 0;
    protected $flagged = 0;
    protected $flag_count = 0;
    protected $upvotes = 0;
    protected $downvotes = 0;
    protected $closed = 0;
	protected $active = 0;

    protected $children = array();

    public $user = false;
    public $topic = false;

	protected static $table_name = 'comments';

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
        return (int)$this->user_id;
    }

    /**
     * Get the id for the topic
     * which this comment is on.
     * 
     * @return int
     */
    public function getTopicId()
    {
        return (int)$this->topic_id;
    }

    /**
     * Get the user who posted this
     * comment.
     * 
     * @return UserModel
     */
    public function getUser()
    {
        if(!$this->user) {        
            $this->user = UserModel::findById($this->getUserId());
        }
        return $this->user;
    }

    /**
     * Get the commenting users picture
     * 
     * @return string
     */
    public function getUserPicture()
    {
        return $this->getUser()->getPicture(true);
    }

    /**
     * Gets the value of parent_comment_id.
     *
     * @return int
     */
    public function getParentCommentId()
    {
        return (int)$this->parent_comment_id;
    }

    /**
     * Get the parent comment
     * 
     * @return CommentModel
     */
    public function getParent()
    {
        return self::findById($this->getParentCommentId());
    }

    /**
     * Gets the value of message.
     *
     * @return mixed
     */
    public function getMessage()
    {
        return $this->message;
    }

    /**
     * Gets the value of archived.
     *
     * @return mixed
     */
    public function isArchived()
    {
        return (bool)$this->archived;
    }

    /**
     * Gets the value of flagged.
     *
     * @return mixed
     */
    public function isFlagged()
    {
        return (bool)$this->flagged;
    }

    /**
     * Gets the value of flag_count.
     *
     * @return mixed
     */
    public function getFlagCount()
    {
        return (int)$this->flag_count;
    }

    /**
     * Gets the value of upvotes.
     *
     * @return mixed
     */
    public function getUpvotes()
    {
        return $this->upvotes;
    }

    /**
     * Gets the value of downvotes.
     *
     * @return mixed
     */
    public function getDownvotes()
    {
        return $this->downvotes;
    }

    /**
     * Gets the value of active.
     *
     * @return mixed
     */
    public function isActive()
    {
        return (bool)$this->active;
    }

    /**
     * Gets the value of closed.
     *
     * @return mixed
     */
    public function isClosed()
    {
        return (bool)$this->closed;
    }

    /**
     * Grab all the children for this comment
     * 
     * @return 
     */
    public function getChildren()
    {
        if(empty($this->children)) {
            $this->children = self::find(array('parent_comment_id = :id', 'active = 1', 'archived = 0', 'topic_id = :topic'), array('id' => $this->getId(), 'topic' => $this->getTopicId()));
        }

        return $this->children;
    }

    /**
     * Get the topic model for this
     * comment.
     * 
     * @return TopicModel
     */
    public function getTopic()
    {
        if(!$this->topic) {
            $this->topic = TopicModel::findById($this->getTopicId());
        }
        return $this->topic;
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
     * Increment the upvotes
     */
    public function incrementUpvotes()
    {
        self::update($this->getId(), array('upvotes' => $this->getUpvotes() + 1));
        $this->upvotes += 1;
    }

    /**
     * Decrement the upvotes
     */
    public function decrementUpvotes()
    {
        self::update($this->getId(), array('upvotes' => $this->getUpvotes() - 1));
        $this->upvotes -= 1;
    }

    /**
     * Increment the downvotes
     */
    public function incrementDownvotes()
    {
        self::update($this->getId(), array('downvotes' => $this->getDownvotes() + 1));
        $this->downvotes += 1;
    }

    /**
     * Decrement the downvotes
     */
    public function decrementDownvotes()
    {
        self::update($this->getId(), array('downvotes' => $this->getDownvotes() - 1));
        $this->downvotes -= 1;
    }

    /**
     * Do we notify the user who posted this
     * comment when someone replies?
     * 
     * @return boolean
     */
    public function isUserNotifiedByReplies()
    {
        $user = $this->getUser();
        if($user->isBanned() || !$user->isActive()) return false;
        $details = UserDetailsModel::findByUser($user);
        return $details->getRepliesToComments();
    }

    /**
     * Delete a comment
     * 
     * @param  int $id
     * @return void
     */
    public static function delete($id)
    {
        return self::update($id, array(
            'archived' => 1,
            'active' => 0,
            'deleted_at' => time()
        ));
    }

    /**
     * Find all comments by a topic, and group
     * them by their parents if they have any.
     * 
     * @param  int $topic_id ID of the topic this Comment is for
     * @param  boolean $without_parent Find those which don't have a parent if this is true
     * @return comments
     */
    public static function findByTopic($topic_id, $without_parent = true, $offset = 0, $amount = 5)
    {
        $where = array('topic_id = ' . $topic_id, 'active = 1', 'archived = 0');

        if($without_parent) {
            $where[] = 'parent_comment_id is null';
        }

        return self::find($where, null, 'order by created_at desc limit ' . $offset . ',' . $amount);
    }

    /**
     * Count all comments by a topic, and group
     * them by their parents if they have any.
     * 
     * @param  int $topic_id ID of the topic this Comment is for
     * @param  boolean $without_parent Find those which don't have a parent if this is true
     * @return comments
     */
    public static function countByTopic($topic_id, $without_parent = true)
    {
        $where = array('topic_id = ' . $topic_id, 'active = 1', 'archived = 0');

        if($without_parent) {
            $where[] = 'parent_comment_id is null';
        }

        return self::count($where);
    }

    /**
     * Get the total number of comments by user
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function getCountByUser(UserModel $user)
    {
        return self::count(array('user_id = :uid'), array('uid' => $user->getId()));
    }

    /**
     * Check whether the user has
     * flagged this comment
     * 
     * @return bool
     */
    public function userFlagged($user = false)
    {
        if(!$user) $user = App::getLoggedInUser();
        if(!$user) return false;
        $flag = CommentFlagModel::getCommentFlagByUser($this, $user);
        return $this->isFlagged() && ($this->getFlagCount() > 0) && (bool)$flag;
    }

    /**
     * Flag this comment
     * 
     * @return CommentModel
     */
    public function flag()
    {
        $comment = self::update($this->getId(), array(
            'flagged' => 1,
            'flag_count' => $this->getFlagCount() + 1
        ));
        $this->flagged = true;
        $this->flag_count++;
        return $comment;
    }

    /**
     * Remove the flag from this comment
     * 
     * @return CommentModel
     */
    public function removeFlag()
    {
        $comment = self::update($this->getId(), array(
            'flagged' => 0,
            'flag_count' => 0
        ));
        $this->flagged = false;
        $this->flag_count = 0;
        return $comment;
    }

    /**
     * Close this comment
     * 
     * @return CommentModel
     */
    public function close()
    {
        $comment = self::update($this->getId(), array(
            'closed' => 1,
        ));
        $this->closed = true;
        return $comment;
    }
    
    /**
     * Can a user interact with this comment? maybe it's closed
     * or it's theirs.
     * 
     * @return boolean
     */
    public function userCanInteract()
    {   
        $user = App::getLoggedInUser();
        if($user) {
            // if($user->getId() == $this->getUserId()) return false;
            if($user->isBanned() || $user->isArchived()) return false;
        }

        return true;
    }

    /**
     * Get the url for this topic
     * 
     * @return string
     */
    public function getUrl()
    {
        return $this->getTopic()->getUrl();
    }
}