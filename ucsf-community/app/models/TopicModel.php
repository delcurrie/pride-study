<?php

use Carbon\Carbon;

class TopicModel extends BaseModel implements JsonSerializable, FlaggableModel, VotableModel, SubscribableModel {

	public $id = 0;
    public $title = '';
    public $description = '';
    public $user_id = 0;
    public $topic_category_id = 0;
    public $archived = 0;
    public $flagged = 0;
    public $flag_count = 0;
    public $featured = 0;
    public $upvotes = 0;
    public $downvotes = 0;
    public $score = 0;
    public $created_at = 0;
    public $updated_at = 0;
    public $deleted_at = 0;
    public $active = 0;

    public $user = false;
    public $comments = false;

	protected static $table_name = 'topics';

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
     * Gets the value of title.
     *
     * @return mixed
     */
    public function getTitle()
    {
        return $this->title;
    }

    /**
     * Gets the value of description.
     *
     * @return mixed
     */
    public function getDescription()
    {
        return $this->description;
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
     * Get the user associated to this topic
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
     * Get the username of the user
     * who posted this topic.
     *
     * @return String
     */
    public function getUserName()
    {
        if ($this->isFeatured()) {
            return 'Admin';
        }

        $user = $this->getUser();

        if($user) {
            return $user->getScreenName();
        }

        return 'Admin';
    }

    /**
     * Get a string/human format of how long
     * ago this topic was posted.
     *
     * @return string
     */
    public function getTimeAgo()
    {
        $created_at = Carbon::createFromTimestamp($this->getCreatedAt());
        return $created_at->diffForHumans();
    }

    /**
     * Gets the value of topic_category_id.
     *
     * @return mixed
     */
    public function getTopicCategoryId()
    {
        return $this->topic_category_id;
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
        return $this->flag_count;
    }

    /**
     * Gets the value of featured.
     *
     * @return mixed
     */
    public function isFeatured()
    {
        return (bool)$this->featured;
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
     * Gets the value of score.
     *
     * @return mixed
     */
    public function getScore()
    {
        return $this->score;
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
     * Gets the value of deleted_at.
     *
     * @return mixed
     */
    public function getDeletedAt()
    {
        return $this->deleted_at;
    }

    /**
     * Gets the value of active.
     *
     * @return mixed
     */
    public function getActive()
    {
        return $this->active;
    }

    /**
     * Is the user subscribed to this topic?
     *
     * @return bool
     */
    public function userSubscribed($user = false)
    {
        if(!$user) $user = App::getLoggedInUser();
        if(!$user) return false;
        return (bool)TopicSubscriptionModel::getSubscribedToTopic($user, $this);
    }

    /**
     * Get an array of all users subscribed to this topic
     *
     * @return Array<UserModel>
     */
    public function getSubscribers()
    {
        return TopicSubscriptionModel::getUsersByTopic($this);
    }

    /**
     * Calculate the topics score
     *
     * @return int
     */
    public function calculateScore($update = true)
    {
        $upvotes = (int)$this->getUpvotes();
        $downvotes = (int)$this->getDownvotes();

        $calculator = new WilsonConfidenceIntervalCalculator();
        $this->score = $calculator->getScore($upvotes, $upvotes + $downvotes);

        if($update) {
            $topic = self::update($this->getId(), array('score' => $this->score));
            return $topic->getScore();
        }

        return $this->score;
    }

    /**
     * Get the url for this topic
     *
     * @return string
     */
    public function getUrl($full = false)
    {
        return ($full ? HTTPS_URL_BASE : URL_BASE) . 'community/topics/' . $this->getId();
    }

    /**
     * Get all comments for this post
     *
     * @return Collection<CommentModel>
     */
    public function getComments()
    {
        if(!$this->comments) {
            $this->comments = CommentModel::findByTopic($this->getId(), false, 0, 9999);
        }

        return $this->comments;
    }

    /**
     * Get the total number of comments
     * for this topic.
     *
     * @return int
     */
    public function getCommentCount()
    {
        $comments = $this->getComments();
        return count($comments);
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
     * Check whether a user has upvoted this
     *
     * @return bool
     */
    public function userUpvoted($user = false)
    {
        if(!$user) $user = App::getLoggedInUser();
        if(!$user) return false;
        $vote = TopicVoteModel::getTopicVoteByUser($this, $user);
        return (bool)$vote && $vote->isUpvote();
    }

    /**
     * Check whether a user has downvoted this
     *
     * @return bool
     */
    public function userDownvoted($user = false)
    {
        if(!$user) $user = App::getLoggedInUser();
        if(!$user) return false;
        $vote = TopicVoteModel::getTopicVoteByUser($this, $user);
        return (bool)$vote && !$vote->isUpvote();
    }

    /**
     * Check whether the user has
     * flagged this topic
     *
     * @return bool
     */
    public function userFlagged($user = false)
    {
        if(!$user) $user = App::getLoggedInUser();
        if(!$user) return false;
        $flag = TopicFlagModel::getTopicFlagByUser($this, $user);
        return $this->isFlagged() && ($this->getFlagCount() > 0) && (bool)$flag;
    }

    /**
     * Flag this topic
     *
     * @return TopicModel
     */
    public function flag()
    {
        $topic = self::update($this->getId(), array(
            'flagged' => 1,
            'flag_count' => $this->getFlagCount() + 1
        ));
        $this->flagged = true;
        $this->flag_count++;
        return $topic;
    }

    /**
     * Remove a single flag from this topic
     *
     * @return TopicModel
     */
    public function unflag()
    {
        $this->flag_count -= 1;
        $this->flagged = (int)($this->flag_count > 0);
        $topic = self::update($this->getId(), array(
            'flagged' => $this->flagged,
            'flag_count' => $this->getFlagCount()
        ));
        return $topic;
    }

    /**
     * Remove the flag from this topic
     *
     * @return TopicModel
     */
    public function removeFlag()
    {
        $topic = self::update($this->getId(), array(
            'flagged' => 0,
            'flag_count' => 0
        ));
        $this->flagged = false;
        $this->flag_count = 0;
        return $topic;
    }

    /**
     * Do we notify the user who posted this
     * topic when someone replies?
     *
     * @return boolean
     */
    public function isUserNotifiedByReplies()
    {
        $user = $this->getUser();
        if(!$user) return false;
        if($user->isBanned() || !$user->isActive()) return false;
        $details = UserDetailsModel::findByUser($user);
        return $details->getRepliesToPosts();
    }

    /**
     * Mark this topic as deleted
     *
     * !active & deleted_at === deleted
     *
     * @return void
     */
    public static function delete($id)
    {
        return self::update($id, array(
            'active' => 0,
            'deleted_at' => time()
        ));
    }

    /**
     * Mark this topic as deactivated
     *
     * !active === deactivated
     *
     * @return void
     */
    public static function deactivate($id)
    {
        return self::update($id, array(
            'active' => 0
        ));
    }

    /**
     * Mark this topic as activated
     *
     * active
     *
     * @return void
     */
    public static function activate($id)
    {
        return self::update($id, array(
            'active' => 1
        ));
    }

    /**
     * Mark this topic as archived
     *
     * @return void
     */
    public static function archive($id)
    {
        return self::update($id, array(
            'archived' => 1,
            'updated_at' => time()
        ));
    }

    /**
     * Get the total number of posts by user
     *
     * @param  UserModel $user
     * @return int
     */
    public static function getCountByUser(UserModel $user)
    {
        return self::count(array('user_id = :uid'), array('uid' => $user->getId()));
    }

    /**
     * Filter by view and category
     *
     * @param  string $view_slug
     * @param  string $category_slug
     * @return Array<TopicModel>
     */
    public static function filter($view_slug = false, $category_slug = false, $limit = 5, $offset = 0)
    {
        $db = Database::getInstance();
        $query = self::buildFilterQuery($view_slug, $category_slug);

        $query->extra .= ' limit ' . $offset . ',' . $limit;
        $sql = 'select t.* from topics t' . (!empty($query->joins) ? ' join ' . join(' join ', $query->joins) : '') . ($query->where ? ' where ' . $query->where : '') . ' ' . $query->extra;
        $topics_query = $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);

        $topics = array();
        if($topics_query) {
            foreach($topics_query as $topic) {
                $topics[] = TopicModel::build($topic);
            }
        }

        return $topics;
    }

    /**
     * Count filter by view and category
     *
     * @param  string $view_slug
     * @param  string $category_slug
     * @return int
     */
    public static function countByFilter($view_slug = false, $category_slug = false)
    {
        $db = Database::getInstance();
        $query = self::buildFilterQuery($view_slug, $category_slug);

        $sql = 'select count(*) as count from topics t' . (!empty($query->joins) ? ' join ' . join(' join ', $query->joins) : '') . ($query->where ? ' where ' . $query->where : '');

        return (int)$db->query($sql)->fetchColumn();
    }

    /**
     * Build the filter query where, extra and any
     * joins that we need.
     *
     * @param  String $view_slug
     * @param  String $category_slug
     * @return object
     */
    private static function buildFilterQuery($view_slug = false, $category_slug = false)
    {
        $where = false;
        $extra = false;
        $joins = array();

        switch($view_slug) {
            case 'new':
                $where = 't.active = 1 and t.archived = 0';
                $extra = 'order by t.featured desc, t.created_at desc';
                break;
            case 'subscribed':
                $where = 't.active = 1';
                $extra = 'order by t.featured desc';
                if(App::loggedIn()) {
                    $where = 't.active = 1 and ts.user_id = ' . App::getLoggedInUser()->getId();
                    $joins[] = 'topic_subscriptions ts on t.id = ts.topic_id';
                }
                break;
            case 'archived':
                $where = 't.archived = 1 and t.active = 1';
                $extra = 'order by t.featured desc';
                break;
            case 'top':
            default :
                $where = 't.active = 1 and t.archived = 0';
                $extra = 'order by t.featured desc, t.score desc';
                break;
        }

        if($category_slug) {
            $category = TopicCategoryModel::findBySlug($category_slug);

            if($category) {
                if($where) $where .= ' and ';
                $joins[] = 'topics_to_topic_categories ttc on t.id = ttc.topic_id';
                $where .= ' ttc.topic_category_id = ' . $category->getId();
            }
        }

        return (object)compact('where', 'extra', 'joins');
    }

    /**
     * Find topics by a search term
     *
     * @param  string $term
     * @return Array<TopicModel>
     */
    public static function findByTerm($term = '', $limit = 10, $offset = 0)
    {
        return self::find(array('(title like :term or description like :term) and active = 1'), array('term' => '%'.$term.'%'), 'order by featured desc, score desc limit ' . $offset .','.$limit);
    }

    /**
     * Count topics by a search term
     *
     * @param  string $term
     * @return Array<TopicModel>
     */
    public static function countByTerm($term = '')
    {
        return self::count(array('(title like :term or description like :term) and active = 1'), array('term' => '%'.$term.'%'));
    }

    /**
     * Get all categories for this topic
     *
     * @return Array<TopicCategoryModel>
     */
    public function getCategories()
    {
        $db = Database::getInstance();
        $categories_query = $db->query('select tc.* from topic_categories tc join topics_to_topic_categories ttc on tc.id = ttc.topic_category_id where ttc.topic_id = ' . (int)$this->getId())->fetchAll(PDO::FETCH_ASSOC);
        $categories = array();
        foreach($categories_query as $category) {
            $categories[] = TopicCategoryModel::build($category);
        }
        return $categories;
    }

    /**
     * Serialize this object for json
     * 
     * @return Array
     */
    public function jsonSerialize()
    {
        return $this->toArray();
    }
}