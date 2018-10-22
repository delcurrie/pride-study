<?php 

/**
 * Represent a notification recipient
 */
class Recipient {

	protected $name = '';
	protected $email = '';

	/**
	 * Construct a new recipient
	 * 
	 * @param String $name
	 * @param String $email
	 */
	public function __construct($name, $email)
	{
		$this->setName($name);
		$this->setEmail($email);
	}

    /**
     * Gets the value of name.
     *
     * @return mixed
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * Sets the value of name.
     *
     * @param mixed $name the name
     *
     * @return self
     */
    protected function setName($name)
    {
        $this->name = $name;

        return $this;
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
     * Sets the value of email.
     *
     * @param mixed $email the email
     *
     * @return self
     */
    protected function setEmail($email)
    {
        $this->email = $email;

        return $this;
    }
}