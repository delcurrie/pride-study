<?php 

/**
 * Represent the Topic List module
 */
class TopicListModule extends BaseModule {

	public $topics = array(),
		   $preview_mode = true,
		   $single_topic_view = false;
		   
	protected $view = 'TopicList.php';

	public function process()
	{
		$this->user = App::getLoggedInUser();
		if($this->user) {		
			$this->preview_mode = !$this->user->hasScreenName();
		}
		$this->render();
	}
}