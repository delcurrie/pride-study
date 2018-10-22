<?php 

class NotificationsModule extends BaseModule
{

	protected $view = 'Notifications.php';

	public $details = false;

	public function process()
	{
		if (!$this->details) {
			$this->details = App::getLoggedInUser()->getDetails();
		}
		
		$this->render();
	}

}