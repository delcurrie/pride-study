<?php 

/**
 * Represent a vote on a comment
 */
class CommentVoteModel extends BaseModel implements VoteInterface
{

    protected $id = 0;
    protected $comment_id = 0;
    protected $user_id = 0;
    protected $upvote = 1;
    protected $created_at = 0;
    protected $updated_at = 0;

    protected static $table_name = 'comment_voters';

    private $comment = false;

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
     * Gets the value of comment_id.
     *
     * @return int
     */
    public function getCommentId()
    {
        return (int)$this->comment_id;
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
     * Get the comment associated to this vote
     * 
     * @return CommentModel
     */
    public function getComment()
    {
        if (!$this->comment) {
            $this->comment = CommentModel::findById($this->getCommentId());
        }

        return $this->comment;
    }

    /**
     * Find votes for a comment by user
     *
     * @param  CommentModel $comment
     * @param  UserModel $user
     * @return CommentVoteModel
     */
    public static function getCommentVoteByUser(CommentModel $comment, UserModel $user)
    {
        if (!$comment) {
            return false;
        }
        return current(self::find(array('user_id = :uid', 'comment_id = :tid'), array(
            'uid' => $user->getId(),
            'tid' => $comment->getId()
        )));
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
     * @return Array<CommentVoteModel>         
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
     * @return Array<CommentVoteModel>         
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
     * Define the method from our interface
     * so we know what text needs to be displayed.
     * 
     * @return String
     */
    public function getVoteText()
    {
        return $this->getComment()->getMessage();
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
        $comment = $this->getComment();

        if (!$comment) {
            return '';
        }

        $topic = $comment->getTopic();

        if (!$topic) {
            return '';
        }

        return $topic->getUrl();
    }

    /**
     * Handle creating rows for a comment vote
     * 
     * @param  array  $data 
     * @return CommentVoteModel     
     */
    public static function createRows($data = array())
    {
        $comment_vote = self::create($data);
        $user_vote = UserVoteModel::create(array(
            'comment_voter_id' => $comment_vote->getId(),
            'user_id' => $comment_vote->getUserId(),
            'upvote' => (int)$comment_vote->isUpvote(),
            'created_at' => $data['created_at'],
            'updated_at' => $data['updated_at'],
            'is_topic_vote' => 0
        ));
        return $comment_vote;
    }

    /**
     * Handle deleting rows for a comment vote
     * @param  int $id
     * @return void     
     */
    public static function deleteRows($id)
    {
        self::delete($id);
        UserVoteModel::deleteByCommentVoteId($id);
    }

    /**
     * Handle updating rows for a comment vote
     * 
     * @param  int $id
     * @param  array  $data
     * @return CommentVoteModel       
     */
    public static function updateRows($id, $data = array())
    {
        $comment_vote = self::update($id, $data);
        $user_vote = UserVoteModel::updateByCommentVoteId($id, $data);
        return $comment_vote;
    }

    /**
     * Handle creating necessary data for a downvote
     * 
     * @param  UserModel    $user
     * @param  CommentModel $comment
     * @return CommentVoteModel                
     */
    public static function handleDownvote(UserModel $user, CommentModel $comment)
    {
        $time = time();
        $vote = self::getCommentVoteByUser($comment, $user);
        if ($vote) {
            if (!$vote->isUpvote()) {
                self::deleteRows($vote->getId());
                $comment->decrementDownvotes();
                return false;
            } else {
                $comment->incrementDownvotes();
                $comment->decrementUpvotes();
                $comment_vote = self::updateRows($vote->getId(), array('upvote' => 0, 'updated_at' => $time));
                return $comment_vote;
            }
        } else {
            $comment->incrementDownvotes();
            $comment_vote = self::createRows(array(
                'comment_id' => $comment->getId(),
                'user_id' => $user->getId(),
                'upvote' => 0,
                'created_at' => $time,
                'updated_at' => $time
            ));

            return $comment_vote;
        }
    }

    /**
     * Handle creating necessary data for a Upvote
     * 
     * @param  UserModel    $user
     * @param  CommentModel $comment
     * @return CommentVoteModel                
     */
    public static function handleUpvote(UserModel $user, CommentModel $comment)
    {
        $time = time();
        $vote = self::getCommentVoteByUser($comment, $user);
        if ($vote) {
            if ($vote->isUpvote()) {
                self::deleteRows($vote->getId());
                $comment->decrementUpvotes();
                return false;
            } else {
                $comment->incrementUpvotes();
                $comment->decrementDownvotes();
                $comment_vote = self::updateRows($vote->getId(), array('upvote' => 1, 'updated_at' => $time));
                return $comment_vote;
            }
        } else {
            $comment->incrementUpvotes();
            $comment_vote = self::createRows(array(
                'comment_id' => $comment->getId(),
                'user_id' => $user->getId(),
                'upvote' => 1,
                'created_at' => $time,
                'updated_at' => $time
            ));

            return $comment_vote;
        }
    }
}
