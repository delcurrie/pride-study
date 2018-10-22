<?php

/**
 * Handle implmentation v1.0 of Community
 * API.
 */
class APIV1Controller extends BaseController
{

    protected $routes = array(
        '/create-account' => array(
            'POST' => array('action' => 'doCreateAccount'),
        ),
        '/update-account' => array(
            'POST' => array('action' => 'doUpdateAccount'),
        ),
        '/check-email' => array(
            'POST' => array('action' => 'doCheckEmail'),
        ),
        '/deactivate-account' => array(
            'POST' => array('action' => 'doDeactivateAccount'),
        ),
        '/create-screen-name' => array(
            'POST' => array('action' => 'doCreateScreenName'),
        ),
        '/create-topic' => array(
            'POST' => array('action' => 'doCreateTopic'),
        ),
        '/get-categories' => array(
            'GET' => array('action' => 'doGetCategories'),
        ),
        '/set-notifications' => array(
            'POST' => array('action' => 'doSetNotifications'),
        ),
        '/get-notifications' => array(
            'GET' => array('action' => 'doGetNotifications'),
        ),
        '/posts/best' => array(
            'GET' => array('action' => 'getTopPosts'),
        ),
        '/topics' => array(
            'GET' => array('action' => 'getCountTopicsByDays'),
        ),
        '/categories' => array(
            'GET' => array('action' => 'getCategories'),
        ),
    );

    private $api_key = 'b5f57a04942888e927f6827164444832';

    /**
     * Handle the create account request
     * through the api.
     *
     * @return json
     */
    public function doCreateAccount()
    {
        $response = array(
            'result' => 'error',
            'data'   => array(),
            'errors' => array()
        );

        // Check that the request is coming from
        // an authorized source
        if ($this->checkAuthentication()) {

            // We can grab the POST'd data and
            // create a new user from it.
            // We then need to add the user id to the
            // data field in the response json.

            // Validate POST data
            $validator = Validator::make($_POST, array(
                'email' => 'required',
                'id'    => 'required'
            ))->process();

            // Return errors if failure
            if ($validator->failed()) {
                $response['errors'] = $validator->getErrors();
                $response['result'] = 'error';
                header("Content-Type: application/json");
                die(json_encode($response));
            }

            // Format user row data
            $user_data = array(
                'email_address' => (string)$_POST['email'],
                'app_id'        => (int)$_POST['id'],
                'created_at'    => time(),
                'requires_notification_setup' => 1
            );

            // Create a new user row
            $user = UserModel::create($user_data);

            // Format user details row data
            $user_details_data = array(
                'user_id' => $user->getId(),
            );

            // Create new user details row
            $details = UserDetailsModel::create($user_details_data);
            $response['result'] = 'success';
            $response['data']['user_id'] = $user->getId();
        }

        header("Content-Type: application/json");
        die(json_encode($response));
    }

    /**
     * Handle the update account request
     * through the api.
     *
     * @return json
     */
    public function doUpdateAccount()
    {
        $response = array(
            'result' => 'error',
            'data'   => array()
        );

        if ($this->checkAuthentication()) {

            // We can grab the POST'd data and
            // update a user from it.
            // We then need to add the user id to the
            // data field in the response json.

            // Validate POST data
            $validator = Validator::make($_POST, array(
                'user_id'       => 'required',
                'community_id'  => 'required',
                'email'         => 'required|valid_email',
            ))->process();

            // Return errors if failure
            if ($validator->failed()) {
                $response['errors'] = $validator->getErrors();
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $id = (int)$_POST['community_id'];

            $user = UserModel::findById($id);
            if (!$user) {
                $response['errors']['community_id'] = 'There is no user with that ID';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            // Work out what data needs updating
            $user_data = array();
            $time = time();

            if (isset($_POST['user_id'])) {
                $user_data['app_id'] = (string)$_POST['user_id'];
            }

            if (isset($_POST['email'])) {
                $user_data['email_address'] = (string)$_POST['email'];
            }

            if (!empty($user_data)) {
                $user_data['updated_at'] = $time;
                $user = UserModel::update($id, $user_data);
            }

            $response['data']['user_id'] = $user->getId();
            $response['data']['updated_at'] = $time;
            $response['result'] = 'success';
        }

        header("Content-Type: application/json");
        die(json_encode($response));
    }

    /**
     * Handle checking to see if there's already a user
     * with an email which has been posted to this endpoint.
     *
     * @return json
     */
    public function doCheckEmail()
    {
        $response = array(
            'result' => 'error',
            'data'   => array()
        );

        if ($this->checkAuthentication()) {
            if (isset($_POST['email'])) {
                $check = (bool)UserModel::findByEmail($_POST['email']);

                $response['result'] = 'success';
                $response['data']['exists'] = $check;
            }
        }

        header("Content-Type: application/json");
        die(json_encode($response));
    }

    /**
     * Handle POST request to deactivate the account
     *
     * @return json
     */
    public function doDeactivateAccount()
    {
        if ($this->checkAuthentication()) {
            if (isset($_POST['user_id']) && is_numeric($_POST['user_id'])) {
                UserModel::deactivate((int)$_POST['user_id']);
                die('Deactivated');
            }

            die('Unable to deactivate');
        }
    }

    /**
     * Handle creating a screen name
     * for an existing community user.
     *
     * @return json
     */
    public function doCreateScreenName()
    {
        $db = Database::getInstance();
        $response = array(
            'result' => 'error',
            'data'   => array()
        );

        header("Content-Type: application/json");

        if ($this->checkAuthentication()) {
            // Validate POST data
            $validator = Validator::make($_POST, array(
                'user_id'       => 'required',
                'community_id'  => 'required',
                'screen_name'   => 'required',
            ))->process();

            // Return errors if failure
            if ($validator->failed()) {
                $response['errors'] = $validator->getErrors();
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $id = (int)$_POST['community_id'];
            $app_id = (int)$_POST['user_id'];

            $user = current(UserModel::find(
                array(
                    'id = :id',
                    'app_id = :app_id',
                    'active = 1',
                    'archived = 0',
                ),
                array(
                    'app_id' => $app_id,
                    'id'     => $id,
                )
            ));

            if (!$user) {
                $response['errors']['community_id'] = 'There is no user with that ID';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $details = UserDetailsModel::findByUser($user);
            if ($details->getScreenName() != '') {
                $response['errors']['screen_name'] = 'has_screen_name';
                $response['data']['screen_name'] = true;
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $screen_name = $_POST['screen_name'];
            $exists = (bool)$db->query('select count(*) from users_details where screen_name = ' . $db->quote($screen_name))->fetchColumn();

            if ($exists) {
                $response['errors']['screen_name'] = 'duplicate';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $details = UserDetailsModel::update($details->getId(), array('screen_name' => $screen_name));
            $user = UserModel::update($user->getId(), array('username' => $screen_name));

            if (!$details) {
                $response['errors']['community_id'] = 'Unable to update screen name';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $response['data'] = array(
                'user_id'      => $_POST['user_id'],
                'community_id' => $_POST['community_id'],
                'screen_name'  => $_POST['screen_name'],
            );
            $response['result'] = 'success';
        }

        die(json_encode($response));
    }

    /**
     * Handle creating a topic via an
     * API request for a community user.
     *
     * @return json
     */
    public function doCreateTopic()
    {
        $db = Database::getInstance();
        $response = array(
            'result' => 'error',
            'data'   => array()
        );

        header("Content-Type: application/json");

        if ($this->checkAuthentication()) {
            // Validate POST data
            $validator = Validator::make($_POST, array(
                'user_id'       => 'required',
                'community_id'  => 'required',
                'title'       => 'required',
                'description' => 'required'
            ))->process();

            // Return errors if failure
            if ($validator->failed()) {
                $response['errors'] = $validator->getErrors();
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $id = (int)$_POST['community_id'];
            $app_id = (int)$_POST['user_id'];

            $user = current(UserModel::find(
                array(
                    'id = :id',
                    'app_id = :app_id',
                    'active = 1',
                    'archived = 0',
                ),
                array(
                    'app_id' => $app_id,
                    'id'     => $id,
                )
            ));

            if (!$user) {
                $response['errors']['community_id'] = 'There is no user with that ID';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            // Extract topic data
            $title = htmlspecialchars(trim($_POST['title']));
            $description = htmlspecialchars(trim($_POST['description']));
            $categories = array();
            if (isset($_POST['topic_categories'])) {
                $categories = $_POST['topic_categories'];
            }

            // Handle existing topics
            $exists = TopicModel::find(array('title = :title'), array(':title' => $title), 'limit 1');
            if (isset($exists[0])) {
                $response['errors']['title'] = 'duplicate';
                die(json_encode($response));
            }

            // Create the topic
            $topic = TopicModel::create(array(
                'title'       => $title,
                'description' => $description,
                'user_id'     => $id,
                'created_at'  => time(),
                'active'      => 1
            ));

            // If we couldn't create it for some reason, tell the users
            if (!$topic) {
                $response['errors']['title'] = 'Unable to create topic.';
                die(json_encode($response));
            }

            foreach ($categories as $category) {
                $db->perform('topics_to_topic_categories', array(
                    'topic_category_id' => (int)$category,
                    'topic_id' => $topic->getId(),
                ));
            }

            // Fire an event to say the topic
            // has been posted.
            TopicEventHandler::fire('topic.post', $topic);

            $response['data']['topic'] = array(
                'id' => $topic->getId(),
                'title' => $title,
                'description' => $description,
                'topic_categories' => $categories
            );

            $response['data']['community_id'] = $id;
            $response['data']['user_id'] = $app_id;
            $response['result'] = 'success';
        }

        die(json_encode($response));
    }

    /**
     * Handle fetching the categories
     *
     * @return json
     */
    public function doGetCategories($group = false)
    {
        $response = array(
            'result' => 'error',
            'data'   => array()
        );

        header("Content-Type: application/json");

        if ($this->checkAuthentication()) {
            $categories = TopicCategoryModel::findGroupedByType(false);
            
            if ($group && isset($categories[$group])) {
                $categories = $categories[$group];
            }

            $response['data']['categories'] = $categories;
            $response['result'] = 'success';
        }

        die(json_encode($response));
    }

    public function doSetNotifications()
    {
        $db = Database::getInstance();
        $response = array(
            'result' => 'error',
            'data'   => array()
        );

        header("Content-Type: application/json");

        if ($this->checkAuthentication()) {
            // Validate POST data
            $validator = Validator::make($_POST, array(
                'user_id'       => 'required',
                'community_id'  => 'required',
                'new_posts'           => 'required|integer',
                'replies_to_posts'    => 'required|integer',
                'replies_to_comments' => 'required|integer',
            ))->process();

            // Return errors if failure
            if ($validator->failed()) {
                $response['errors'] = $validator->getErrors();
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $id = (int)$_POST['community_id'];
            $app_id = (int)$_POST['user_id'];

            $user = current(UserModel::find(
                array(
                    'id = :id',
                    'app_id = :app_id',
                    'active = 1',
                    'archived = 0',
                ),
                array(
                    'app_id' => $app_id,
                    'id'     => $id,
                )
            ));

            if (!$user) {
                $response['errors']['community_id'] = 'There is no user with that ID';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $user = UserModel::update($user->getId(), array(
                'requires_notification_setup' => 0
            ));

            $details = $user->getDetails();

            if (!$details) {
                $response['errors']['community_id'] = 'Unable to fetch existing notification settings';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $details = UserDetailsModel::update($details->getId(), array(
                'new_posts'           => (int)$_POST['new_posts'],
                'replies_to_posts'    => (int)$_POST['replies_to_posts'],
                'replies_to_comments' => (int)$_POST['replies_to_comments'],
            ));

            if (!$details) {
                $response['errors']['community_id'] = 'Unable to update notification settings';
                $response['result'] = 'error';
                die(json_encode($response));
            }

            $response['data']['community_id'] = $id;
            $response['data']['user_id'] = $app_id;
            $response['result'] = 'success';
        }

        die(json_encode($response));
    }

    public function doGetNotifications()
    {
        $db = Database::getInstance();
        $response = array(
            'result' => 'success',
            'data'   => array()
        );

        header("Content-Type: application/json");

        $this->checkAuthentication();

        $id = (int)$_GET['community_id'];
        $app_id = (int)$_GET['user_id'];

        $user = current(UserModel::find(
            array(
                'id = :id',
                'app_id = :app_id',
                'active = 1',
                'archived = 0',
            ),
            array(
                'app_id' => $app_id,
                'id'     => $id,
            )
        ));

        if (!$user) {
            $response['errors']['community_id'] = 'There is no user with that ID';
            $response['result'] = 'error';
            die(json_encode($response));
        }

        $details = $user->getDetails();

        $response['data'] = array(
            'notification_setting_comments_on_posts' => $details->getRepliesToPosts(),
            'notification_setting_new_posts'         => $details->getNewPosts(),
            'notification_setting_replies_to_posts'  => $details->getRepliesToComments(),
        );

        $response['user_id'] = $user->getId();

        die(json_encode($response));
    }

    /**
     * Get {n} top posts
     * 
     * @return json
     */
    public function getTopPosts()
    {
        $limit = 5;

        if (isset($_REQUEST['limit'])) {
            $limit = (int)$_REQUEST['limit'];
        }

        header("Content-Type: application/json");

        $topics = TopicModel::find(array(
            'active = 1',
            'archived = 0',
        ), array(), 'order by featured desc, score desc limit ' . $limit);

        $formatted_topics = array();

        foreach ($topics as $i => $topic) {
            $formatted_topic = array(
                'type' => 'posts',
                'id'   => $topic->getId(),
                'attributes' => array(
                    'title'        => $topic->getTitle(),
                    'postedAt'     => date("Y-m-d\TH:i:s.u\Z", $topic->getCreatedAt()),
                    'guid'         => $topic->getId(),
                    'score'        => $topic->getScore(),
                    'baseScore'    => 0,
                    'upvotes'      => $topic->getUpvotes(),
                    'downvotes'    => $topic->getDownvotes(),
                    'body'         => $topic->getDescription(),
                    'commentCount' => $topic->getCommentCount(),
                    'rank'         => $i + 1,
                ),
                'links' => array(
                    'self' => $topic->getUrl(true)
                )
            );
            $formatted_topics[] = $formatted_topic;
        }

        die(json_encode(array(
            'data' => $formatted_topics
        )));
    }

    /**
     * Get the total count of topics
     * posted in the last {n} days.
     * 
     * @return json
     */
    public function getCountTopicsByDays()
    {
        $days = 7;
        if (isset($_REQUEST['days'])) {
            $days = min((int)$_REQUEST['days'], 365);
        }

        header("Content-Type: application/json");

        $day_data = array();
        foreach (range($days - 1, 0, -1) as $day) {
            $date = strtotime("-$day days");

            $db = Database::getInstance();
            $sql = 'select DATE(FROM_UNIXTIME(created_at)) as date, count(id) as count from topics where active = 1 and archived = 0 and DATE(FROM_UNIXTIME(created_at)) = DATE(FROM_UNIXTIME(' . $date . ')) group by DATE(FROM_UNIXTIME(created_at))';
            $row = $db->query($sql)->fetch(PDO::FETCH_ASSOC);

            $date_parts = explode('-', $row['date']);
            $day_data[] = array(
                'year'  => (string)date('Y', $date),
                'month' => (string)date('n', $date),
                'day'   => (string)date('j', $date),
                'date'  => date('Y-m-d', $date) . 'T00:00:00.000Z',
                'posts' => (int)$row['count'],
            );
        }

        die(json_encode(array(
            'data' => $day_data
        )));
    }

    /**
     * Get categories
     * 
     * @return json
     */
    public function getCategories()
    {   
        $response = array(
            'data'   => array()
        );

        $group = false;
        if (isset($_REQUEST['group'])) {        
            $group = (string)$_REQUEST['group'];
        }

        header("Content-Type: application/json");

        $categories = TopicCategoryModel::find(array(
            'type = :type',
            'active = 1'
        ), array(
            'type' => $group
        ));

        $formatted_categories = array();
        $count_group = 0;

        foreach ($categories as $order => $category) {
            $count = $category->getCountTopics();
            $count_group += $count;

            $formatted_categories[] = array(
                'type' => 'categories',
                'id' => $category->getId(),
                'attributes' => array(
                    'name'      => $category->getName(),
                    'order'     => $order+1,
                    'postCount' => $count,
                )
            );
        }

        $response['result'] = 'success';
        $response['data'] = $formatted_categories;
        $response['meta'] = array(
            'groupName'      => $group,
            'groupPostCount' => $count_group
        );

        die(json_encode($response));
    }

    /**
     * Make sure we're getting a request from
     * an authorised source.
     *
     * @return boolean
     */
    private function checkAuthentication()
    {
        $headers = apache_request_headers();
        foreach ($headers as $header_name => $header_value) {
            if (strtoupper($header_name) == 'PRIDE-API-AUTH' && $header_value == $this->api_key) {
                return true;
            }
        }

        header("HTTP/1.0 401 Unauthorized");
        die(json_encode(array(
            'unauthorized' => true
        )));
    }
}

/**
 * 1) When user signs up with app, hit API endpoint in community to create account
 * 2) When user access community, send token and user id to community
 * 3) Community will authenticate token and user id against app API
 * 4) If API returns community id, auto-login the user
 * 5) If API returns no community id, show login
 * 6) Have button on login page for "create account", which will automatically create the the community account, and hit app API endpoint "/update-account-community-id"
 */
