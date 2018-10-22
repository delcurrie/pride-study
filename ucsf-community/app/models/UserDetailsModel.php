<?php 

/**
 * Represent the specific user details in the
 * database
 */
class UserDetailsModel extends BaseModel {

	protected $id = 0;
	protected $user_id = 0;
    protected $picture = '';
    protected $screen_name = '';
    protected $new_posts = 0;
    protected $replies_to_posts = '';
	protected $replies_to_comments = '';

	protected static $table_name = 'users_details';

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
     * Gets the value of picture.
     *
     * @return mixed
     */
    public function getPicture($full = false)
    {
        if(!$full) return $this->picture;
        return URL_BASE.'assets/img/'.$this->picture;
    }

    /**
     * Find these details by user
     * 
     * @param  UserModel $user
     * @return 
     */
    public static function findByUser(UserModel $user)
    {
    	return current(self::find(array('user_id = :id'), array('id' => $user->getId())));
    }

    /**
     * Gets the value of screen_name.
     *
     * @return mixed
     */
    public function getScreenName()
    {
        return $this->screen_name;
    }

    /**
     * Gets the value of new_posts.
     *
     * @return mixed
     */
    public function getNewPosts()
    {
        return $this->new_posts;
    }

    /**
     * Gets the value of replies_to_posts.
     *
     * @return mixed
     */
    public function getRepliesToPosts()
    {
        return $this->replies_to_posts;
    }

    /**
     * Gets the value of replies_to_posts.
     *
     * @return mixed
     */
    public function getRepliesToComments()
    {
        return $this->replies_to_comments;
    }
}