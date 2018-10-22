<?php

/**
 * Handles main home views
 *
 * @author Analog Republic
 */
class HomeController extends BaseController {

    protected $routes = array();

    /**
     * Auth endpoint
     *
     * @return void
     */
    public function authenticate()
    {
        App::authenticateWithAPI();
        // if not ok result die with error
        // otherwise log them in and go to welcome page if no screen name else go to community
    }

    /**
     * Show the welcome
     * @return view
     */
    public function showWelcome()
    {
        App::requireAppSession();
    	if(App::loggedIn() && App::getLoggedInUser()->hasScreenName())  {
            App::redirect(URL_BASE.'community');
        }

        $app = App::getInstance();

        $slides = SlideModel::findInOrder();
        $app->template->set('slides', $slides);

        $app->template->setModuleVar('Header', 'body_classes', 'white-background');
        $app->template->setModuleVar('Navigation', 'show_filters', false);
        $app->template->addSlick();
        $app->template->addRequiredJS('pages/welcome.js');
        $app->template->render('Welcome.php');
    }

    /**
     * Show the main community view
     * @return view
     */
    public function showCommunity()
    {
        App::requireAppSession();
        $app = App::getInstance();

        $view_filter = false;
        if(isset($_GET['view'])) {
            $view_filter = $_GET['view'];
        }

        $category_filter = false;
        if(isset($_GET['category'])) {
            $category_filter = $_GET['category'];
        }

        $term = false;
        if(isset($_GET['term'])) {
            $term = $_GET['term'];
        }

        $offset = 0;
        if(isset($_GET['offset'])) {
            $offset = (int)$_GET['offset'];
        }

        $limit = 5;
        if(isset($_GET['limit'])) {
            $limit = (int)$_GET['limit'];
        }

        if($term) {
            $topics = TopicModel::findByTerm($term, $limit, $offset);
        } else {
            $topics = TopicModel::filter($view_filter, $category_filter, $limit, $offset);
        }

        $app->template->setModuleVar('TopicList', 'topics', $topics);
        $app->template->set('topics', $topics);

        $app->template->addRequiredJS('pages/topics/general.js');
        $app->template->addRequiredJS('pages/topics/loading.js');
        $app->template->render('Home.php');
    }

    public function showNoAppWarning()
    {
        echo '<h1>Please visit the community through the UCSF app.</h1>';
    }

}