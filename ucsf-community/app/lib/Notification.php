<?php

/**
 * Create an abstract notification builder.
 */
class Notification {

	public static $instance = false;

	public $recipients = array();
	public $emails = array();

	/**
	 * Get instance of notification class
	 *
	 * @return Notification
	 */
	public static function getInstance()
	{
		if(!self::$instance) {
			self::$instance = new Notification();
		}
		return self::$instance;
	}

	/**
	 * Build a new notification
	 *
	 * @param Array<Recipient> $recipients An Array of recipients
	 * @param String $template
	 * @param Array<mixed> $data
	 * @return Notification
	 */
	public function build($recipients = array(), $subject = '', $template = '', $data = array())
	{
		$this->recipients = $recipients;
		foreach($this->recipients as $recipient) {

			if(!$recipient instanceof Recipient) {
				throw new Exception('Invalid recipient provided');
			}

			try {
				$email = new Email();
				$email->setFromName(EMAIL_FROM_NAME)
				      ->setFromEmail(EMAIL_FROM)
				      ->setIsText(false)
				      ->setToName($recipient->getName())
				      ->setToEmail($recipient->getEmail())
				      ->setTemplate($template)
				      ->setSubject($subject)
				      ->setReplacements(array_merge($data, array(
				      	'name'  => $recipient->getName(),
				      	'email' => $recipient->getEmail()
				      )));
				$this->emails[$recipient->getEmail()] = $email;
			} catch (Exception $e) {}
		}
	}

	/**
	 * Send all of the emails we've built up.
	 */
	public function send($preview = false, $keep_emails = false)
	{
		foreach($this->emails as $addr => $email) {
			try {
				if($preview) die($email->preview());
				$email->send();
			} catch(Exception $e) {
				$logger = new Katzgrau\KLogger\Logger(__DIR__.'/email_failure_logs');
				$logger->error('Unable to send email to: ' . $addr . ' -- ' . $e->getMessage());
			}
		}

		if (!$keep_emails) {
			$this->emails = array();
		}
	}

	/**
     * Check to see if the email is in our allowed list
     * if not, then ignore it
     * 
     * @param  String  $email
     * @return boolean
     */
    public static function isAllowedEmailAddress($email)
    {
        $email = strtolower($email);

        if(strpos($email, '@hellothread.com') != -1) {
            return true;
        }

        return in_array($email, array(
            'test@test.com',
        ));
    }
}