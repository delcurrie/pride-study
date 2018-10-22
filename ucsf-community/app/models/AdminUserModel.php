<?php 

/**
 * Represent an admin user in the database
 */
class AdminUserModel extends BaseModel {

	protected $id = 0;
	protected $username = '';
	protected $email = '';
	protected $password = '';
	protected $receive_notifications = 0;
	protected $active = 0;

	protected static $table_name = 'admin_users';

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
     * Gets the value of username.
     *
     * @return mixed
     */
    public function getUsername()
    {
        return $this->username;
    }

    /**
     * Gets the value of email.
     *
     * @return mixed
     */
    public function getEmail()
    {
        return $this->email;
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
     * Gets the value of receive_notifications.
     *
     * @return boolean
     */
    public function doesReceiveNotifications()
    {
        return (bool)$this->receive_notifications;
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
     * Get admins which can be notified 
     * 
     * @return Array<AdminUserModel>
     */
    public static function getNotifiable()
    {
    	return self::find(array('active = 1', 'receive_notifications = 1'));
    }
}