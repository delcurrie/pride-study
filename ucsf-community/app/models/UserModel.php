<?php

class UserModel extends BaseModel
{

    // Restriction values
    const NO_RESTRICTION = 0;
    const DISALLOW_VOTING = 1;
    const DISALLOW_TOPICS = 2;
    const DISALLOW_COMMENTS = 3;

    protected $id = 0;
    protected $username = '';
    protected $password = '';
    protected $email_address = '';
    protected $password_reset_key = '';
    protected $password_reset_date = '';
    protected $banned = 0;
    protected $created_at = 0;
    protected $updated_at = 0;
    protected $requires_notification_setup = false;
    protected $active = 0;

    protected $details = '';

    protected static $table_name = 'users';

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
     * Gets the value of username.
     *
     * @return mixed
     */
    public function getUsername()
    {
        return $this->username;
    }

    /**
     * Gets the value of password.
     *
     * @return mixed
     */
    public function getPassword()
    {
        return $this->password;
    }

    /**
     * Gets the value of email_address.
     *
     * @return mixed
     */
    public function getEmailAddress()
    {
        return $this->email_address;
    }

    /**
     * Gets the value of password_reset_key.
     *
     * @return mixed
     */
    public function getPasswordResetKey()
    {
        return $this->password_reset_key;
    }

    /**
     * Gets the value of password_reset_date.
     *
     * @return mixed
     */
    public function getPasswordResetDate()
    {
        return $this->password_reset_date;
    }

    /**
     * Grab the users profile picture
     *
     * @return string
     */
    public function getPicture($full = false)
    {
        return $this->getDetails()->getPicture($full);
    }

    /**
     * Get the users details object
     *
     * @param  boolean $force
     * @return UserDetailsModel
     */
    public function getDetails($force = false)
    {
        if (!$this->details || $force) {
            $this->details = UserDetailsModel::findByUser($this);
        }

        return $this->details;
    }

    /**
     * Check to see if this user is an admin
     *
     * @return boolean
     */
    public function isAdmin()
    {
        return $this->role == 'admin';
    }

    /**
     * Gets the value of banned.
     *
     * @return mixed
     */
    public function isBanned()
    {
        return (bool)$this->banned;
    }

    /**
     * Gets the value of restriction_type.
     *
     * @return mixed
     */
    public function getRestrictionType()
    {
        return (int)$this->restriction_type;
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
     * Check whether or not the user is archived
     *
     * @return boolean
     */
    public function isArchived()
    {
        return (bool)$this->archived;
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
     * Get the intial of the username
     * for this user.
     *
     * @return char (string)
     */
    public function getInitial()
    {
        $details = $this->getDetails();
        if ($details) {
            $this->username = $details->getScreenName();
        }
        return strtoupper(substr($this->username, 0, 1));
    }

    /**
     * Get the screen name
     *
     * @return char (string)
     */
    public function getScreenName()
    {
        $details = $this->getDetails();
        if ($details) {
            $this->username = $details->getScreenName();
        }
        return $this->username;
    }

    /**
     * Ban a user
     *
     * @return void
     */
    public function ban()
    {
        self::update($this->getId(), array(
            'banned' => 1
        ));
        $this->toggleAppCommuntiyBan();
    }

    /**
     * Remove a ban
     *
     * @return void
     */
    public function removeBan()
    {
        self::update($this->getId(), array(
            'banned' => 0
        ));
        $this->toggleAppCommuntiyBan();
    }

    /**
     * Get the users restrictions
     *
     * @return Array<int>
     */
    public function getRestrictions()
    {
        $db = Database::getInstance();
        if (!$this->restrictions) {
            $this->restrictions = array();
            $restrictions = $db->query('select * from users_restrictions where user_id = ' . $this->getId())->fetchAll(PDO::FETCH_ASSOC);

            foreach ($restrictions as $restriction) {
                $this->restrictions[] = (int)$restriction['type_id'];
            }
        }

        return $this->restrictions;
    }

    /**
     * Can a user flag something
     *
     * @param  FlaggableModel $item
     * @return boolean
     */
    public function canFlag($item = false)
    {
        $allowed = $this->hasScreenName() && !$this->isArchived() && !$this->isBanned();

        if ($item && $item instanceof FlaggableModel) {
            if ($item->getUserId() == $this->getId() || $item->isArchived()) {
                $allowed = false;
            }
        }

        return $allowed;
    }

    /**
     * Can a user subscribe to something
     *
     * @param  SubscribableModel $item
     * @return boolean
     */
    public function canSubscribe($item = false)
    {
        $allowed = $this->hasScreenName() && !$this->isArchived() && !$this->isBanned();

        if ($item && $item instanceof SubscribableModel) {
            if ($item->getUserId() == $this->getId() || $item->isArchived()) {
                $allowed = false;
            }
        }

        return $allowed;
    }

    /**
     * Can this user vote?
     *
     * @param  VotableModel $item
     * @return boolean
     */
    public function canVote($item = false)
    {
        $allowed = $this->hasScreenName() && !$this->isArchived() && !in_array(self::DISALLOW_VOTING, $this->getRestrictions()) && !$this->isBanned();

        if ($item && $item->isArchived()) {
            return false;
        }

        if ($item && $item instanceof VotableModel) {
            if ($item->getUserId() == $this->getId() || $item->isArchived()) {
                $allowed = false;
            }
        }

        return $allowed;
    }

    /**
     * Can this user reply to a comment?
     *
     * @param  CommentModel $comment
     * @return Boolean
     */
    public function canReply(CommentModel $comment)
    {
        $allowed = $this->canPostComments() && !$comment->isClosed();
        return $allowed;
    }

    /**
     * Can this user post topics?
     *
     * @return boolean
     */
    public function canPostTopics()
    {
        return $this->hasScreenName() && !$this->isArchived() && !in_array(self::DISALLOW_TOPICS, $this->getRestrictions()) && !$this->isBanned();
    }

    /**
     * Can this user post comments?
     *
     * @return boolean
     */
    public function canPostComments()
    {
        return $this->hasScreenName() && !$this->isArchived() && !in_array(self::DISALLOW_COMMENTS, $this->getRestrictions()) && !$this->isBanned();
    }

    /**
     * Reset a users password trigger
     *
     * @return void
     */
    public function triggerResetPassword()
    {
        $token = md5(time() . $this->getId() . $this->getEmailAddress());

        self::update($this->getId(), array(
            'password_reset_key' => $token,
            'password_reset_date' => time()
        ));

        //$this->sendPasswordResetEmail($token, $this->getId());
    }

    /**
     * Subscribe to a topic by it's id
     *
     * @param int $topic_id
     * @return bool
     */
    public function toggleSubscribe($topic_id)
    {
        $topic = TopicModel::findById($topic_id);
        if ($topic) {
            $already_subscribed = $this->subscribed($topic);
            if (!$already_subscribed) {
                return TopicSubscriptionModel::create(array(
                    'topic_id' => $topic_id,
                    'user_id'  => $this->getId()
                ));
            } else {
                TopicSubscriptionModel::delete($already_subscribed->getId());
                return false; // false denotes allowing subscription
            }
            return false;
        }
        return false;
    }

    /**
     * Check whether or not the user has
     * subscribed to a topic, given a
     * topic.
     *
     * @param  TopicModel $topid
     * @return bool
     */
    public function subscribed($topic)
    {
        return TopicSubscriptionModel::getSubscribedToTopic($this, $topic);
    }

    /**
     * Toggle the upvote on a topic
     *
     * @param int $topic_id
     */
    public function toggleUpvote(TopicModel $topic)
    {
        return TopicVoteModel::handleUpvote($this, $topic);
    }

    /**
     * Toggle the downvote on a topic
     *
     * @param int $topic_id
     */
    public function toggleDownvote(TopicModel $topic)
    {
        return TopicVoteModel::handleDownvote($this, $topic);
    }

    /**
     * Check whether this user has upvoted a topic
     *
     * @param  TopicModel $topic
     * @return boolean
     */
    public function hasUpvotedFor(TopicModel $topic)
    {
        $vote = TopicVoteModel::getTopicVoteByUser($topic, $this);
        return (bool)$vote && $vote->isUpvote();
    }

    /**
     * Check whether this user has downvoted a topic
     *
     * @param  TopicModel $topic
     * @return boolean
     */
    public function hasDownvotedFor(TopicModel $topic)
    {
        $vote = TopicVoteModel::getTopicVoteByUser($topic, $this);
        return (bool)$vote && !$vote->isUpvote();
    }

    /**
     * Check whether this user has upvoted a topic
     *
     * @param  CommentModel $topic
     * @return boolean
     */
    public function hasUpvotedForComment(CommentModel $topic)
    {
        $vote = CommentVoteModel::getTopicVoteByUser($topic, $this);
        return (bool)$vote && $vote->isUpvote();
    }

    /**
     * Check whether this user has downvoted a topic
     *
     * @param  CommentModel $topic
     * @return boolean
     */
    public function hasDownvotedForComment(CommentModel $topic)
    {
        $vote = CommentVoteModel::getTopicVoteByUser($topic, $this);
        return (bool)$vote && !$vote->isUpvote();
    }

    /**
     * Toggle the upvote on a comment
     *
     * @param int $comment_id
     */
    public function toggleUpvoteComment(CommentModel $comment)
    {
        return CommentVoteModel::handleUpvote($this, $comment);
    }

    /**
     * Toggle the downvote on a comment
     *
     * @param int $topic_id
     */
    public function toggleDownvoteComment(CommentModel $comment)
    {
        return CommentVoteModel::handleDownvote($this, $comment);
    }

    /**
     * Flag a topic
     *
     * @param  TopicModel $topic
     * @return TopicFlagModel
     */
    public function flagTopic(TopicModel $topic)
    {
        if (!$topic->userFlagged() && $this->canFlag($topic)) {
            $topic->flag();
            return (bool)TopicFlagModel::create(array(
                'user_id' => $this->getId(),
                'topic_id' => $topic->getId()
            ));
        }

        return false;
    }

    /**
     * Un-Flag a topic
     *
     * @param  TopicModel $topic
     * @return TopicFlagModel
     */
    public function unflagTopic(TopicModel $topic)
    {
        if ($topic->userFlagged() && $this->canFlag($topic)) {
            $topic->unflag();
            $flag = current(TopicFlagModel::find(array(
                'user_id' => $this->getId(),
                'topic_id' => $topic->getId()
            )));
            TopicFlagModel::delete($flag->getId());
            return true;
        }

        return false;
    }

    /**
     * Flag a comment
     *
     * @param  CommentModel $comment
     * @return CommentFlagModel
     */
    public function flagComment(CommentModel $comment)
    {
        if (!$comment->userFlagged() && $this->canFlag($comment)) {
            $comment->flag();
            return (bool)CommentFlagModel::create(array(
                'user_id' => $this->getId(),
                'comment_id' => $comment->getId()
            ));
        }

        return false;
    }

    /**
     * Un-Flag a comment
     *
     * @param  CommentModel $comment
     * @return CommentFlagModel
     */
    public function unflagComment(CommentModel $comment)
    {
        if ($comment->userFlagged() && $this->canFlag($comment)) {
            $comment->removeflag();
            $comment_flag = current(CommentFlagModel::find(array(
                'user_id = ' . $this->getId(),
                'comment_id = ' . $comment->getId()
            )));

            if ($comment_flag) {
                CommentFlagModel::delete($comment_flag->getId());
                return true;
            }
        }

        return false;
    }

    /**
     * Get all topics this user has
     * subscribed to.
     *
     * @return Array<TopicModel>
     */
    public function getSubscribedTopics()
    {
        return TopicSubscriptionModel::getTopicsByUser($this);
    }

    /**
     * Get the count of topics this user has made
     *
     * @return int
     */
    public function getTopicCount()
    {
        return TopicModel::getCountByUser($this);
    }

    /**
     * Get the count of comments by this user
     *
     * @return int
     */
    public function getCommentCount()
    {
        return CommentModel::getCountByUser($this);
    }

    /**
     * Get the total number of upvotes for this
     * user.
     *
     * @return int
     */
    public function getUpvoteCount()
    {
        return UserVoteModel::getCountUpvotesByUser($this);
    }

    /**
     * Get the total number of downvotes for this
     * user.
     *
     * @return int
     */
    public function getDownvoteCount()
    {
        return UserVoteModel::getCountDownvotesByUser($this);
    }

    /**
     * Check if we have a screen name
     *
     * @return boolean
     */
    public function hasScreenName()
    {
        $details = $this->getDetails();
        if (!$details) {
            return false;
        }
        return $details->getScreenName() != null;
    }

    /**
     * Get n latest topics from this user
     *
     * @param  integer $limit
     * @return Array<TopicModel>
     */
    public function getLatestTopics($limit = 10, $offset = 0)
    {
        return TopicModel::find(array('user_id = :uid'), array('uid' => $this->getId()), 'order by created_at desc limit ' . $limit . ' offset ' . $offset);
    }

    /**
     * Get count latest topics from this user
     *
     * @return int
     */
    public function countLatestTopics()
    {
        return TopicModel::count(array('user_id = :uid'), array('uid' => $this->getId()));
    }

    /**
     * Get the users latest comments
     *
     * @param  integer $limit
     * @return Array<CommentModel>
     */
    public function getLatestComments($limit = 10, $offset = 0)
    {
        return CommentModel::find(array('user_id = :uid'), array('uid' => $this->getId()), 'order by created_at desc limit ' . $limit . ' offset ' . $offset);
    }

    /**
     * Get count latest Comments from this user
     *
     * @return int
     */
    public function countLatestComments()
    {
        return CommentModel::count(array('user_id = :uid'), array('uid' => $this->getId()));
    }

    /**
     * Get the users latest subscriptions
     *
     * @param  integer $limit
     * @return Array<TopicModel>
     */
    public function getLatestSubscribedTopics($limit = 10)
    {
        $subscriptions = TopicSubscriptionModel::findByUser($this, 'order by id desc limit ' . $limit);
        $topics = array();
        foreach ($subscriptions as $sub) {
            $topics[] = $sub->getTopic();
        }
        return $topics;
    }

    /**
     * Get the latest upvoted topics for this user
     *
     * @param  integer $limit
     * @return Array<TopicModel>
     */
    public function getLatestUpvotedTopics($limit = 10, $offset = 0)
    {
        $upvotes = UserVoteModel::getUpvotesByUser($this, 'order by created_at desc limit ' . $limit . ' offset ' . $offset);
        $votes = array();
        foreach ($upvotes as $upvote) {
            $votes[] = $upvote->getRow();
        }

        return $votes;
    }

    /**
     * Get the count of latest upvoted topics for this user
     *
     * @return Array<TopicModel>
     */
    public function countLatestUpvotedTopics()
    {
        return UserVoteModel::countUpvotesByUser($this);
    }

    /**
     * Get the latest downvoted topics for this user
     *
     * @param  integer $limit
     * @return Array<TopicModel>
     */
    public function getLatestDownvotedTopics($limit = 10, $offset = 0)
    {
        $downvotes = UserVoteModel::getDownvotesByUser($this, 'order by created_at desc limit ' . $limit . ' offset ' . $offset);
        $votes = array();
        foreach ($downvotes as $downvote) {
            $votes[] = $downvote->getRow();
        }

        return $votes;
    }

    /**
     * Get the count of latest downvoted topics for this user
     *
     * @return Array<TopicModel>
     */
    public function countLatestDownvotedTopics()
    {
        return UserVoteModel::countDownvotesByUser($this);
    }

    /**
     * Get all users which are notified by new posts
     *
     * @return Array<UserModel>
     */
    public static function findNotifiedByNewPosts()
    {
        $db = Database::getInstance();

        $sql = 'select u.* from users u join users_details ud on u.id = ud.user_id where ud.new_posts = 1 and u.active = 1 and u.banned = 0';
        $user_query = $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);

        $users = array();
        foreach ($user_query as $user) {
            $users[] = UserModel::build($user);
        }

        return $users;
    }

    /**
     * Find a user by their email
     *
     * @param  String $email
     * @return UserModel
     */
    public static function findByEmail($email)
    {
        return current(self::find(array('email_address = :email'), array('email' => $email), 'limit 1'));
    }

    /**
     * deactivate a users account
     *
     * @param  int $id
     * @return UserModel
     */
    public static function deactivate($id)
    {
        return UserModel::update($id, array(
            'archived'    => 1,
            'updated_at'  => time(),
            'archived_at' => time()
        ));
    }

    /**
     * activate a users account
     *
     * @param  int $id
     * @return UserModel
     */
    public static function activate($id)
    {
        return UserModel::update($id, array(
            'active' => 1,
            'updated_at' => time()
        ));
    }

    /**
     * Does this user require notification setup?
     *
     * @return boolean
     */
    public function requiresNotificationSetup()
    {
        return (bool)$this->requires_notification_setup;
    }

    private function toggleAppCommuntiyBan()
    {
        $url = APP_API_URL . '/api/2.0/toggle-community-ban';

        $fields = array(
            'community_id' => $this->id,
        );

        foreach ($fields as $key => $value) {
            $fields_string .= $key . '=' . $value . '&';
        }

        rtrim($fields_string, '&');
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'PRIDE-API-AUTH: '.APP_API_KEY,
        ));

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $result = curl_exec($ch);
        curl_close($ch);
    }
}
