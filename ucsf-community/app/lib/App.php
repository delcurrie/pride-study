<?php
/**
 * @author    Analog Republic
 * @version   1.0
 * @copyright Copyright (c) 2014, Pride Study
 **/

class App {

    static $instance;

    private $vars = array();

    private function __contruct() {}

    public function __set($index, $value) {
        $this->vars[$index] = $value;
    }
    public function __get($index) {
        return $this->vars[$index];
    }
    public function __isset($index) {
        return isset($this->vars[$index]);
    }
    public function __unset($index) {
        unset($this->vars[$index]);
    }

    public static function redirect($url, $code = 301) {
        header("Location: ".$url, true, $code);
        exit();
    }

    public static function getInstance() {
        if (!isset(App::$instance)) {
            App::$instance = new App();
        }
        return App::$instance;
    }

    public static function requireLogin($url = true) {
        if (!self::loggedIn()) {
            setLoginRedirect($url);
            self::redirect(URL_BASE . 'account/login');
        }
    }

    /**
     * Is this likely to be an ajax request?
     *
     * @return boolean
     */
    public static function isAjaxRequest() {
        return !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest';
    }

    /**
     * Log a user into the system
     *
     * @param  Int $id
     * @return Boolean
     */
    public static function loginUser($id, $admin = false) {
        $db = Database::getInstance();
        $user = UserModel::findById($id);
        if ($user) {
            $delete = $db->perform('sessions', 'user_id = ' . (int)$id . ' and admin = ' . ($admin?1:0), 'delete');

            $data = array(
                'session_id' => md5(time() . $id . APP_SESSION_SALT),
                'user_id'    => (int)$id,
                'ip'         => $_SERVER['REMOTE_ADDR'],
                'created_at' => time()
            );

            $insert = $db->perform('sessions', $data);

            App::logoutUser();
            $account = $db->query('select * from users where id = '.(int)$id.' limit 1')->fetch(PDO::FETCH_ASSOC);

            if ($account) {
                $return_data['result'] = 'ok';
                $return_data['account'] = $account;
                $_SESSION['authenticate_response'] = $return_data;
                $_SESSION['logged_in'] = $data['session_id'];
            } else {
                $return_data['result'] = 'error';
            }
            return (bool)$insert;
        }
        return false;
    }

    /**
     * Logout the current session
     *
     * @return void
     */
    public static function logoutUser() {
        $db = Database::getInstance();

        $db->perform('sessions', 'session_id = ' . $db->quote($_SESSION['logged_in']), 'delete');
        unset($_SESSION['logged_in']);
        unset($_SESSION['authenticate_response']);
    }

    /**
     * Check if we've got a logged in session
     *
     * @param  Int $id
     * @return Boolean
     */
    public static function loggedIn() {
        static $logged_in = null;
        if ($logged_in == null) {
            $logged_in = (bool)self::getCurrentLoggedInSession();
        }
        return $logged_in;
    }

    /**
     * Get the user related to the currently logged
     * in session.
     *
     * @return UserModel / Boolean
     */
    public static function getLoggedInUser() {
        static $logged_in_user;
        if ($logged_in_user)
            return $logged_in_user;

        $session = self::getCurrentLoggedInSession();
        $user = UserModel::findById((int)$session['user_id']);

        if ($user) {
            $logged_in_user = $user;
            return $logged_in_user;
        }

        return false;
    }

    /**
     * Get the session for the current login, if there's one
     *
     * @return Boolean / Array
     */
    private static function getCurrentLoggedInSession() {
        static $session = null;
        if ($session)
            return $session;

        if (crawlerDetect()) {
            $session = array(
                'user_id' => 1
            );
            return $session;
        }

        if (isset($_SESSION['logged_in'])) {
            $db = Database::getInstance();
            $session = $db->query('select * from sessions where session_id = ' . $db->quote($_SESSION['logged_in']) . ' order by created_at desc limit 1')->fetch(PDO::FETCH_ASSOC);
            return $session;
        }

        return false;
    }

    /**
     * Authenticate with the PRIDE study
     * api endpoint to log in the app user.
     *
     * @return void
     */
    public static function authenticateWithAPI() {


        /**
         * Send request to API with token and user_id
         * Check response to see if success
         * log in user with returned community_id
         * if no community_id show welcome view
         */
        // We need all of the data to make the request
        if (!isset($_GET['token']) || !isset($_GET['user_id'])) return;

        // Url for request
        $url = APP_API_URL . '/api/2.0/confirm-community-token';

        $fields = array(
            'user_id' => urlencode($_GET['user_id']),
            'token'   => urlencode($_GET['token']),
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

        if (isset($json_response['result']) && $json_response['result'] == 'ok') {

            $_SESSION['authenticate_response'] = $json_response;

            if (!isset($json_response['account']['community_id']) || $json_response['account']['community_id'] == '0') {
                $json_response['token'] = $_GET['token'];

                self::redirect(URL_BASE.'account/login');
                die();
            }

            // Log them in
            $login = App::loginUser((int)$json_response['account']['community_id']);

            if ($json_response['account']['archived'] == 1) {
                self::redirect(URL_BASE.'community');
                die();
            }

            if ($login) {
                self::redirect(URL_BASE);
                die();
            } else {
                die('<h1> Unknown error occured please try and again. Code 1004</h1>');
            }
        }

        die('<h1> Unknown error occured please try and again. Code: 1003 </h1>');
    }

    /**
     * Check if we have an app session
     *
     * @return boolean
     */
    public static function hasAppSession()
    {
        return isset($_SESSION['authenticate_response']);
    }

    public static function requireAppSession()
    {
        if (!self::hasAppSession()) {
            App::redirect(URL_BASE . 'no-app-warning');
        }
    }

    /**
     * Generate a the login url, so that
     * we can force authenticate users.
     * 
     * @return string
     */
    public static function generateForceLoginUrl($user_id)
    {
        // Url for request
        $url = APP_API_URL . '/api/2.0/generate-community-url';

        $fields = array(
            'user_id' => urlencode($user_id),
        );

        foreach($fields as $key => $value) {
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


        if ($json_response['result'] != 'ok') {
            return false;
        }

        if (isset($json_response['url'])) {
            $url = parse_url($json_response['url']);

            if (isset($url['query'])) {
                return URL_BASE.'authenticate?'.$url['query'];
            }
        }

        return false;
    }

}