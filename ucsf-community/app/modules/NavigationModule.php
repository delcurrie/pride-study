<?php

class NavigationModule extends BaseModule {

	public $is_logged_in = false,
		   $user = false,
		   $posts = array(),
		   $comments = array(),
		   $subscribed = array(),
		   $upvoted = array(),
		   $downvoted = array(),
		   $selected_type = '',
		   $selected_category = '',
		   $categories = array(),
           $show_filters = true,
           $show_back = false,
           $show_profile = false,
           $is_profile_view = false;

    protected $view = 'Navigation.php';

    public function process() 
    {
        if(!$this->is_logged_in) {
        	$this->is_logged_in = false;
        }

        if(empty($this->categories)) {
        	$this->categories = TopicCategoryModel::findGroupedByType();
        }

        $category = false;
        if(empty($this->selected_category) && isset($_GET['category'])) {
        	$this->selected_category = $_GET['category'];
        	$category = TopicCategoryModel::findBySlug($this->selected_category);
        }

        if($category && empty($this->selected_type)) {	
        	$this->selected_type = $category->getType();
        }

        $app = App::getInstance();
        $url_parts = $app->router->getURIParts();

        $this->is_profile_view = isset($url_parts[1]) && $url_parts[1] == 'profile';

        $this->render();
    }

}
