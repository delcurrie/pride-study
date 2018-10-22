<?php 

class CommentFlagModel extends BaseModel {

	protected $id = 0;
	protected $comment_id = 0;
	protected $user_id = 0;

	protected static $table_name = 'comment_flags';

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
     * Gets the value of comment_id.
     *
     * @return mixed
     */
    public function getCommentId()
    {
        return (int)$this->comment_id;
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
     * Get a flag by comment and user
     * 
     * @param  CommentModel $comment
     * @param  UserModel  $user
     * @return CommentFlagModel
     */
    public static function getCommentFlagByUser(CommentModel $comment, UserModel $user)
    {
    	return current(self::find(array('comment_id = :tid', 'user_id = :uid'), array(
    		'uid' => $user->getId(),
    		'tid' => $comment->getId()
    	)));
    }
}