<?php

/**
 * Handle main account logic
 *
 * @author Analog Republic
 */
class AccountController extends BaseController
{

    protected $routes = array(
        '/create' => array(
            'GET'  => array('name' => 'Create', 'action' => 'showCreateAccount'),
            'POST' => array('action' => 'doCreateAccount'),
        ),
        '/screen-name' => array(
            'GET'  => array('name' => 'Create', 'action' => 'showScreenName'),
            'POST' => array('action' => 'doScreenName'),
        ),
        '/email-notifications' => array(
            'GET'  => array('name' => 'Create', 'action' => 'showEmailNotifications'),
            'POST' => array('action' => 'doEmailNotifications'),
        ),
        '/edit' => array(
            'GET'  => array('name' => 'Edit', 'action' => 'showEditAccount'),
            'POST' => array('action' => 'doEditAccount'),
        ),
        '/profile/topics' => array(
            'GET'  => array('name' => 'Topics', 'action' => 'getTopics'),
        ),
        '/profile/comments' => array(
            'GET'  => array('name' => 'Comments', 'action' => 'getComments'),
        ),
        '/profile/upvoted' => array(
            'GET'  => array('name' => 'Upvoted', 'action' => 'getUpvoted'),
        ),
        '/profile/downvoted' => array(
            'GET'  => array('name' => 'Downvoted', 'action' => 'getDownvoted'),
        ),
        '/profile' => array(
            'GET'  => array('name' => 'Profile', 'action' => 'showProfile'),
        ),
        '/login' => array(
            'GET'  => array('name' => 'Login', 'action' => 'showLogin'),
            'POST' => array('action' => 'doLogin'),
        ),
        '/logout' => array('action' => 'doLogout'),
    );

    public function __construct()
    {
        parent::__construct();
        App::requireAppSession();
    }

    /**
     * Show the account creation view
     * @return view
     */
    public function showCreateAccount()
    {
        if (App::loggedIn()) {
            App::redirect(URL_BASE.'community');
        }
        $app = App::getInstance();

        $app->template->addValidation();
        $app->template->addRequiredJs('pages/account/create.js');
        $app->template->render('Account/Create.php');
    }

    /**
     * Handle account creation requests (POST)
     * @return json
     */
    public function doCreateAccount()
    {
        $app = App::getInstance();
        $response = array(
            'revalidate' => false,
            'errors' => array(),
            'redirect' => false
        );

        // Validate input
        $validator = Validator::make($_POST, array(
            'username' => 'required|min_len,8',
            'password' => 'required',
            'password_confirmation' => 'required',
        ))->process();

        // Check if failed
        if ($validator->failed()) {
            $response['errors'] = $validator->getErrors();
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        $authenticate_response = $_SESSION['authenticate_response'];

        // Extract data
        $username = trim($_POST['username']);
        $password = trim($_POST['password']);
        $email_address = trim($authenticate_response['account']['email']);
        $password_confirmation = trim($_POST['password_confirmation']);

        // Check for existance of user
        $exists = UserModel::count(array('username = :username'), array('username' => $username)) > 0;
        if ($exists) {
            $response['errors']['username'] = 'There is already a user with that name.';
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        // Compare password fields
        if ($password_confirmation != $password) {
            $response['errors']['password_confirmation'] = 'The passwords must match.';
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        // Format details for insertion
        $user_details = array(
            'username' => $username,
            'email_address' => $email_address,
            'password' => password_hash($password, PASSWORD_BCRYPT),
            'created_at' => time(),
        );

        // Create user, handle it not working also
        $user = UserModel::create($user_details);
        $details = UserDetailsModel::create(array(
            'user_id' => $user->getId(),
            'screen_name' => $username,
        ));
        if (!$user && !($user instanceof UserModel)) {
            $response['errors']['username'] = 'Something went wrong when trying to create your account, please try again.';
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        // Url for request
        $url = APP_API_URL . '/api/2.0/update-account-community-id';

        $fields = array(
            'user_id' => urlencode($authenticate_response['account']['id']),
            'token'   => urlencode($authenticate_response['account']['community_token']),
            'community_id'   => urlencode($user->getId()),
        );

        $fields_string = '';
        foreach ($fields as $key => $value) {
            $fields_string .= $key . '=' . $value . '&';
        }

        rtrim($fields_string, '&');
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'PRIDE-API-AUTH: '.APP_API_KEY,
        ));

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $result = curl_exec($ch);
        curl_close($ch);

        // Login and set redirect
        App::loginUser($user->getId(), (int)$user->isAdmin());
        $response['redirect'] = getLoginRedirect('/');

        // Die with a json_encoded response
        die(json_encode($response));
    }

    /**
     * Handle user logout
     * @return void
     */
    public function doLogout()
    {
        App::logoutUser();
        App::redirect(URL_BASE);
        die();
    }

    /**
     * Show the login view
     * @return view
     */
    public function showLogin()
    {
        if (App::loggedIn()) {
            App::redirect(URL_BASE.'community');
        }
        $app = App::getInstance();

        $app->template->addValidation();
        $app->template->addRequiredJs('pages/account/login.js');
        $app->template->render('Account/Login.php');
    }

    /**
     * Handle a login request (POST)
     * @return json
     */
    public function doLogin()
    {
        App::hasAppSession();
        $app = App::getInstance();
        $response = array(
            'revalidate' => false,
            'errors' => array(),
            'redirect' => false
        );

        $authenticate_response = $_SESSION['authenticate_response'];
        $db = Database::getInstance();

        $app_id_check = (bool)$db->query('select count(*) from users where app_id = ' . (int)$authenticate_response['account']['id'])->fetchColumn();

        if ($app_id_check) {
            $response['errors']['username'] = 'Unknown account error. Code: 1001';
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        // Validate input
        $validator = Validator::make($_POST, array(
            'username' => 'required',
            'password' => 'required',
        ))->process();

        // Check if failed
        if ($validator->failed()) {
            $response['errors'] = $validator->getErrors();
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        // Extract data
        $username = trim($_POST['username']);
        $password = trim($_POST['password']);

        // Grab record
        $user = current(UserModel::find(array('username = :username'), array(':username' => $username), 'limit 1'));

        // Check if record exists, then login
        if ($user && $user instanceof UserModel) {
            $password_check = password_verify(hash("sha256", $password), $user->getPassword());

            if ($password_check) {
                $response['user'] = $user->getId();

                // Url for request
                $url = APP_API_URL . '/api/2.0/update-account-community-id';

                $fields = array(
                    'user_id' => urlencode($authenticate_response['account']['id']),
                    'token'   => urlencode($authenticate_response['account']['community_token']),
                    'community_id'   => urlencode($user->getId()),
                );

                foreach ($fields as $key => $value) {
                    $fields_string .= $key . '=' . $value . '&';
                }

                rtrim($fields_string, '&');
                $ch = curl_init();

                curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                    'PRIDE-API-AUTH: '.APP_API_KEY,
                ));

                curl_setopt($ch, CURLOPT_URL, $url);
                curl_setopt($ch, CURLOPT_POST, count($fields));
                curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                $result = curl_exec($ch);
                curl_close($ch);

                $user = UserModel::update($user->getId(), array(
                    'app_id' => (int)$authenticate_response['account']['id'],
                    'email_address' => $authenticate_response['account']['email'],
                ));
                App::loginUser((int)$user->getId(), false);
            } else {
                $response['errors']['username'] = 'The username / password is incorrect.';
            }
        } else {
            $response['errors']['username'] = 'The username / password is incorrect.';
        }

        // If we need revalidating, die a json response
        if ($response['revalidate'] = (count($response['errors']) > 0)) {
            die(json_encode($response));
        }


        // POST TO API

        $response['redirect'] = getLoginRedirect('/');
        die(json_encode($response));
    }

    /**
     * Handle request to show edit account
     * view.
     *
     * @return View
     */
    public function showEditAccount()
    {
        $app = App::getInstance();
        if (!App::loggedIn()) {
            App::redirect(URL_BASE);
        }

        $user = App::getLoggedInUser();

        $app->template->set('user', $user);
        $app->template->set('details', $user->getDetails());

        $app->template->addValidation();
        $app->template->addRequiredJs('pages/account/edit.js');
        $app->template->setModuleVar('Notifications', 'details', $user->getDetails());

        $app->template->render('Account/Edit.php');
    }

    /**
     * Handle request to update account
     *
     * @return json
     */
    public function doEditAccount()
    {
        $app = App::getInstance();
        $response = array(
            'revalidate' => false,
            'errors' => array(),
            'redirect' => false
        );

        if (!App::loggedIn()) {
            throw new NotFoundException();
        }

        // Validate input
        $validator = Validator::make($_POST, array(
            'screen_name' => 'required',
        ))->process();

        // Check if failed
        if ($validator->failed()) {
            $response['errors'] = $validator->getErrors();
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        $screen_name         = (string)$_POST['screen_name'];
        $new_posts           = (isset($_POST['new_posts']) ? 1 : 0);
        $replies_to_posts    = (isset($_POST['replies_to_posts']) ? 1 : 0);
        $replies_to_comments = (isset($_POST['replies_to_comments']) ? 1 : 0);

        // Fetch logged in user
        $user = App::getLoggedInUser();
        $_POST['user_id'] = $user->getId();


        $details = $user->getDetails();

        // Check for a change in the screen name
        if ($user->getScreenName() != $screen_name) {

            $count_existing_user = UserModel::count(array(
                'username = :name',
                'id <> ' . $user->getId()
            ), array(
                'name' => $screen_name
            ));

            $count_existing_details = UserDetailsModel::count(array(
                'screen_name = :name',
                'user_id <> ' . $user->getId()
            ), array(
                'name' => $screen_name
            ));

            // Someone else has it, show error
            if ($count_existing_user > 0 || $count_existing_details > 0) {
                $response['errors'] = array(
                    'screen_name' => 'This screen name is already taken'
                );

                $response['revalidate'] = true;
                die(json_encode($response));
            }

        } else {
            $screen_name = $user->getScreenName();
        }

        // Set update at value for user
        UserModel::update($user->getId(), array(
            'updated_at' => time(),
            'username'   => $screen_name
        ));

        // Update the user details with the new information
        UserDetailsModel::update($details->getId(), array(
            'screen_name'       => $screen_name,
            'new_posts'         => $new_posts,
            'replies_to_posts'  => $replies_to_posts,
            'replies_to_comments' => $replies_to_comments,
        ));

        die(json_encode($response));
    }

    /**
     * Show the screen name view
     *
     * @return view
     */
    public function showScreenName()
    {
        if (App::loggedIn() && App::getLoggedInUser()->hasScreenName()) {
            App::redirect(URL_BASE.'account/email-notifications');
        }

        $app = App::getInstance();

        $app->template->addValidation();
        $app->template->addRequiredJs('pages/account/screen_name.js');
        $app->template->render('Account/CreateScreenName.php');
    }

    /**
     * Handle saving the users screen name
     *
     * @return json
     */
    public function doScreenName()
    {
        $app = App::getInstance();
        $db = Database::getInstance();
        $response = array(
            'revalidate' => false,
            'errors' => array(),
            'redirect' => false
        );

        if (!App::loggedIn()) {
            throw new NotFoundException();
        }

        $validator = Validator::make($_POST, array(
            'screen_name' => 'required|min_len,8'
        ))->process();

        // Check if failed
        if ($validator->failed()) {
            $response['errors'] = $validator->getErrors();
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        $screen_name = $_POST['screen_name'];
        $exists = (bool)$db->query('select count(*) from users_details where screen_name = ' . $db->quote($screen_name))->fetchColumn();

        if ($exists) {
            $response['duplicate'] = true;
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        $session_id = $_SESSION['logged_in'];

        $session_user_id = $db->query('select user_id from sessions where session_id = ' . $db->quote($session_id))->fetch(PDO::FETCH_ASSOC);

        if (!$session_user_id) {
            $response['errors']['screen_name'] = 'Unknown error occured. Code: 1002';
            $response['revalidate'] = true;
            die(json_encode($response));
        }

        $user = UserModel::findById((int)$session_user_id['user_id']);
        $user = UserModel::update($user->getId(), array(
            'username' => $screen_name,
            'updated_at' => time()
        ));

        $user_details = UserDetailsModel::findByUser($user);
        $user_details = UserDetailsModel::update($user_details->getId(), array(
            'screen_name' => $screen_name
        ));

        $url = APP_API_URL . '/api/2.0/update-has-community-screen-name';

        $fields = array(
            'community_id' => $user->getId(),
        );

        foreach ($fields as $key => $value) {
            $fields_string .= $key . '=' . $value . '&';
        }

        rtrim($fields_string, '&');
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'PRIDE-API-AUTH: '.APP_API_KEY,
        ));

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $result = curl_exec($ch);
        curl_close($ch);

        $json_response = json_decode($result, true);

        die(json_encode($response));
    }

    public function showProfile()
    {
        $app = App::getInstance();
        if (!App::loggedIn()) {
            App::redirect(URL_BASE);
        }

        $user = App::getLoggedInUser();

        $app->template->set('user', $user);
        $app->template->set('details', $user->getDetails());

        $app->template->setModuleVar('Navigation', 'show_back', true);

        $app->template->addValidation();
        $app->template->addRequiredJs('pages/account/profile.js');

        $app->template->set('posts', $this->user->getLatestTopics(3));
        $app->template->set('comments', $this->user->getLatestComments(3));
        $app->template->set('upvoted', $this->user->getLatestUpvotedTopics(3));
        $app->template->set('downvoted', $this->user->getLatestDownvotedTopics(3));

        $app->template->render('Account/Profile.php');
    }

    public function getTopics($offset = 0, $limit = 5)
    {
        $app = App::getInstance();
        if (!App::loggedIn()) {
            App::redirect(URL_BASE);
        }

        $user = App::getLoggedInUser();

        $last_page = false;

        if (isset($_GET['offset'])) {
            $offset = (int)$_GET['offset'];
        }

        if (isset($_GET['limit'])) {
            $limit = (int)$_GET['limit'];
        }

        $total = $user->countLatestTopics();
        $topics = $user->getLatestTopics($limit, $offset);

        $app->template->set('posts', $topics);
        $count = count($topics);

        if ($count + $offset >= $total) {
            $last_page = true;
        }

        ob_start();
        $app->template->render('Ajax/Profile/Topics.php');
        $html = ob_get_clean();

        die(json_encode(array(
            'html' => $html,
            'count' => $count,
            'last' => $last_page
        )));
    }

    public function getComments($offset = 0, $limit = 5)
    {
        $app = App::getInstance();
        if (!App::loggedIn()) {
            App::redirect(URL_BASE);
        }

        $last_page = false;
        $user = App::getLoggedInUser();

        if (isset($_GET['offset'])) {
            $offset = (int)$_GET['offset'];
        }

        if (isset($_GET['limit'])) {
            $limit = (int)$_GET['limit'];
        }

        $total = $user->countLatestComments();
        $comments = $user->getLatestComments($limit, $offset);

        $app->template->set('comments', $comments);

        $count = count($comments);

        if ($count + $offset >= $total) {
            $last_page = true;
        }

        ob_start();
        $app->template->render('Ajax/Profile/Comments.php');
        $html = ob_get_clean();

        die(json_encode(array(
            'html' => $html,
            'count' => $count,
            'last' => $last_page
        )));
    }

    public function getUpvoted($offset = 0, $limit = 5)
    {
        $app = App::getInstance();
        if (!App::loggedIn()) {
            App::redirect(URL_BASE);
        }

        $last_page = false;
        $user = App::getLoggedInUser();

        if (isset($_GET['offset'])) {
            $offset = (int)$_GET['offset'];
        }

        if (isset($_GET['limit'])) {
            $limit = (int)$_GET['limit'];
        }

        $total = $user->countLatestUpvotedTopics();
        $upvotes = $user->getLatestUpvotedTopics($limit, $offset);

        $app->template->set('upvoted', $upvotes);
        $count = count($upvotes);

        if ($count + $offset >= $total) {
            $last_page = true;
        }

        ob_start();
        $app->template->render('Ajax/Profile/Upvotes.php');
        $html = ob_get_clean();

        die(json_encode(array(
            'html' => $html,
            'count' => $count,
            'last' => $last_page
        )));
    }

    public function getDownvoted($offset = 0, $limit = 5)
    {
        $app = App::getInstance();
        if (!App::loggedIn()) {
            App::redirect(URL_BASE);
        }

        $last_page = false;
        $user = App::getLoggedInUser();

        if (isset($_GET['offset'])) {
            $offset = (int)$_GET['offset'];
        }

        if (isset($_GET['limit'])) {
            $limit = (int)$_GET['limit'];
        }

        $total = $user->countLatestDownvotedTopics();
        $downvotes = $user->getLatestDownvotedTopics($limit, $offset);

        $app->template->set('downvoted', $downvotes);
        $count = count($downvotes);

        if ($count + $offset >= $total) {
            $last_page = true;
        }

        ob_start();
        $app->template->render('Ajax/Profile/Downvotes.php');
        $html = ob_get_clean();

        die(json_encode(array(
            'html' => $html,
            'count' => $count,
            'last' => $last_page
        )));
    }

    /**
     * Show the email notifications
     *
     * @return void
     */
    public function showEmailNotifications()
    {
        $user = App::getLoggedInUser();

        if (!$user || !$user->requiresNotificationSetup()) {
            App::redirect(URL_BASE.'community');
        }

        $app = App::getInstance();
        $app->template->addValidation();
        $app->template->addRequiredJs('pages/account/email_notifications.js');
        $app->template->setModuleVar('Notifications', 'details', $user->getDetails());
        $app->template->render('Account/Notifications.php', compact('user'));
    }

    /**
     * Handle saving the email notification settings
     *
     * @return json
     */
    public function doEmailNotifications()
    {
        $app = App::getInstance();
        $response = array(
            'revalidate' => false,
            'errors' => array(),
            'redirect' => false
        );

        if (!App::loggedIn()) {
            throw new NotFoundException();
        }

        $new_posts         = (isset($_POST['new_posts']) ? 1 : 0);
        $replies_to_posts  = (isset($_POST['replies_to_posts']) ? 1 : 0);
        $replies_to_comments = (isset($_POST['replies_to_comments']) ? 1 : 0);

        // Fetch logged in user
        $user = App::getLoggedInUser();

        $user = UserModel::update($user->getId(), array(
            'requires_notification_setup' => 0
        ));

        $details = $user->getDetails();

        // Update the user details with the new information
        UserDetailsModel::update($details->getId(), array(
            'new_posts'         => $new_posts,
            'replies_to_posts'  => $replies_to_posts,
            'replies_to_comments' => $replies_to_comments,
        ));

        die(json_encode($response));
    }
}
