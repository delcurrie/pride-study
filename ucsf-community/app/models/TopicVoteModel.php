<?php 

/**
 * Represent a vote on a topic
 */
class TopicVoteModel extends BaseModel implements VoteInterface
{
    protected $id = 0;
    protected $topic_id = 0;
    protected $user_id = 0;
    protected $upvote = 1;
    protected $created_at = 0;
    protected $updated_at = 0;

    protected static $table_name = 'topic_voters';

    private $topic = false;


    /**
     * Gets the value of id.
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
     * @return int
     */
    public function getTopicId()
    {
        return (int)$this->topic_id;
    }

    /**
     * Gets the value of user_id.
     *
     * @return int
     */
    public function getUserId()
    {
        return (int)$this->user_id;
    }

    /**
     * Gets the value of upvote.
     *
     * @return bool
     */
    public function isUpvote()
    {
        return (bool)$this->upvote;
    }

    /**
     * Get the topic associated to this vote
     * 
     * @return TopicModel
     */
    public function getTopic()
    {
        if (!$this->topic) {
            $this->topic = TopicModel::findById($this->getTopicId());
        }

        return $this->topic;
    }

    /**
     * Find votes for a topic by user
     *
     * @param  TopicModel $topic
     * @param  UserModel $user
     * @return TopicVoteModel
     */
    public static function getTopicVoteByUser(TopicModel $topic, UserModel $user)
    {
        if (!$topic) {
            return false;
        }
        if (!$user) {
            return false;
        }

        $vote = current(self::find(array('user_id = :uid', 'topic_id = :tid'), array(
            'uid' => $user->getId(),
            'tid' => $topic->getId()
        )));
        return $vote;
    }

    /**
     * Get the total number of upvotes by user
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function getUpvoteCountByUser(UserModel $user)
    {
        return self::count(array('user_id = :uid', 'upvote = 1'), array('uid' => $user->getId()));
    }

    /**
     * Get the total number of downvotes by user
     * 
     * @param  UserModel $user
     * @return int         
     */
    public static function getDownvoteCountByUser(UserModel $user)
    {
        return self::count(array('user_id = :uid', 'upvote = 0'), array('uid' => $user->getId()));
    }

    /**
     * Get all of the upvotes for
     * a specific user.
     * 
     * @param  UserModel $user
     * @param  string    $extra
     * @return Array<TopicVoteModel>         
     */
    public static function getUpvotesByUser(UserModel $user, $extra = 'order by id desc limit 3')
    {
        return self::find(array('user_id = :uid', 'upvote = 1'), array('uid' => $user->getId()), $extra);
    }

    /**
     * Get all of the downvotes for
     * a specific user.
     * 
     * @param  UserModel $user
     * @param  string    $extra
     * @return Array<TopicVoteModel>         
     */
    public static function getDownvotesByUser(UserModel $user, $extra = 'order by id desc limit 3')
    {
        return self::find(array('user_id = :uid', 'upvote = 0'), array('uid' => $user->getId()), $extra);
    }

    /**
     * Gets the value of created_at.
     *
     * @return String
     */
    public function getCreatedAt()
    {
        return date('m/d/y', $this->created_at);
    }

    /**
     * Gets the value of updated_at.
     *
     * @return String
     */
    public function getUpdatedAt()
    {
        return date('m/d/y', $this->updated_at);
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

    /**
     * Define the method from our interface
     * so we know what text needs to be displayed.
     * 
     * @return String
     */
    public function getVoteText()
    {
        return $this->getTopic()->getTitle();
    }

    /**
     * Method to get the formatted date
     * of the vote which will be displayed
     * when we're listing it.
     * 
     * @return String
     */
    public function getVoteDate()
    {
        return $this->getCreatedAt();
    }

    /**
     * Should return the url to the resource
     * or it's parent resource, used when listing.
     * 
     * @return String
     */
    public function getVoteUrl()
    {
        return $this->getUrl();
    }

    /**
     * Handle creating rows for a topic vote
     * 
     * @param  array  $data 
     * @return TopicVoteModel     
     */
    public static function createRows($data = array())
    {
        $topic_vote = self::create($data);
        $user_vote = UserVoteModel::create(array(
            'topic_voter_id' => $topic_vote->getId(),
            'user_id' => $topic_vote->getUserId(),
            'upvote' => (int)$topic_vote->isUpvote(),
            'created_at' => $data['created_at'],
            'updated_at' => $data['updated_at'],
            'is_topic_vote' => 1
        ));
        return $topic_vote;
    }

    /**
     * Handle deleting rows for a topic vote
     * @param  int $id
     * @return void     
     */
    public static function deleteRows($id)
    {
        self::delete($id);
        UserVoteModel::deleteByTopicVoteId($id);
    }

    /**
     * Handle updating rows for a topic vote
     * 
     * @param  int $id
     * @param  array  $data
     * @return TopicVoteModel       
     */
    public static function updateRows($id, $data = array())
    {
        $topic_vote = self::update($id, $data);
        $user_vote = UserVoteModel::updateByTopicVoteId($id, $data);
        return $topic_vote;
    }

    /**
     * Handle creating necessary data for a downvote
     * 
     * @param  UserModel    $user
     * @param  TopicModel $topic
     * @return TopicVoteModel                
     */
    public static function handleDownvote(UserModel $user, TopicModel $topic)
    {
        $time = time();
        $vote = self::gettopicVoteByUser($topic, $user);
        if ($vote) {
            if (!$vote->isUpvote()) {
                self::deleteRows($vote->getId());
                $topic->decrementDownvotes();
                return false;
            } else {
                $topic->incrementDownvotes();
                $topic->decrementUpvotes();
                $topic_vote = self::updateRows($vote->getId(), array('upvote' => 0, 'updated_at' => $time));
                return $topic_vote;
            }
        } else {
            $topic->incrementDownvotes();
            $topic_vote = self::createRows(array(
                'topic_id' => $topic->getId(),
                'user_id' => $user->getId(),
                'upvote' => 0,
                'created_at' => $time,
                'updated_at' => $time
            ));

            return $topic_vote;
        }
    }

    /**
     * Handle creating necessary data for a Upvote
     * 
     * @param  UserModel    $user
     * @param  TopicModel $topic
     * @return TopicVoteModel                
     */
    public static function handleUpvote(UserModel $user, TopicModel $topic)
    {
        $time = time();
        $vote = self::gettopicVoteByUser($topic, $user);
        if ($vote) {
            if ($vote->isUpvote()) {
                self::deleteRows($vote->getId());
                $topic->decrementUpvotes();
                return false;
            } else {
                $topic->incrementUpvotes();
                $topic->decrementDownvotes();
                $topic_vote = self::updateRows($vote->getId(), array('upvote' => 1, 'updated_at' => $time));
                return $topic_vote;
            }
        } else {
            $topic->incrementUpvotes();
            $topic_vote = self::createRows(array(
                'topic_id' => $topic->getId(),
                'user_id' => $user->getId(),
                'upvote' => 1,
                'created_at' => $time,
                'updated_at' => $time
            ));

            return $topic_vote;
        }
    }
}
