<?php
/**
 * @author    Analog Republic
 * @version   1.0
 * @copyright Copyright (c) 2014, Pride Study
 **/

abstract class BaseController {

    public function __construct() 
    {
        App::authenticateWithAPI();
        $app = App::getInstance();

        if(App::loggedIn()) {
            $this->user = App::getLoggedInUser();

            $account_activated = $this->user->hasScreenName() && !$this->user->isBanned();
            $show_create_screen_name = !$this->user->isArchived() && !$this->user->hasScreenName();

            $app->template->setModuleVar('Navigation', 'user', $this->user);
            $app->template->setModuleVar('Navigation', 'show_profile', $account_activated);
            $app->template->setModuleVar('Navigation', 'show_create_screen_name', $show_create_screen_name);

            $app->template->setModuleVar('Navigation', 'posts', $this->user->getLatestTopics(3));
            $app->template->setModuleVar('Navigation', 'comments', $this->user->getLatestComments(3));
            $app->template->setModuleVar('Navigation', 'upvoted', $this->user->getLatestUpvotedTopics(3));
            $app->template->setModuleVar('Navigation', 'downvoted', $this->user->getLatestDownvotedTopics(3));
        }
        
        $app->template->setModuleVar('Navigation', 'is_logged_in', (bool)App::loggedIn());
    }

    public function Index($params = array()) 
    {
        $app = App::getInstance();
        $app->router->setRoutes($this->routes);
        $app->router->parseRoute();
    }

}
