<?php
error_reporting(E_ALL ^ E_NOTICE);

define('DS', DIRECTORY_SEPARATOR);
define('DIR_ADMININCLUDES', dirname(__FILE__).(substr(dirname(__FILE__), -1)!=DS?DS:''));
define('DIR_ADMINROOT', realpath(DIR_ADMININCLUDES.'..'.DS).DS);
define('DIR_ROOT', dirname(__FILE__) . DS . '..' . DS . '..' . DS);
define('DIR_APP', DIR_ROOT . 'app' . DS);
define('DIR_APP_CACHE', DIR_APP . 'cache' . DS);
define('DIR_APP_CONFIG', DIR_APP . 'config' . DS);
define('DIR_APP_CONTROLLERS', DIR_APP . 'controllers' . DS);
define('DIR_APP_LIB', DIR_APP . 'lib' . DS);
define('DIR_APP_MODELS', DIR_APP . 'models' . DS);
define('DIR_APP_MODULES', DIR_APP . 'modules' . DS);
define('DIR_APP_VIEWS', DIR_APP . 'views' . DS);

require_once DIR_ROOT . 'vendor/autoload.php';

// If it's not the live env, use Whoops
if (SITE_ENVIRONMENT != 'live') {
    $whoops = new \Whoops\Run;
    $whoops->pushHandler(new \Whoops\Handler\PrettyPageHandler);
    $whoops->register();
}

require (DIR_ADMININCLUDES . 'functions.php');
require (DIR_ADMININCLUDES . 'html_functions.php');
require (DIR_APP_LIB . 'functions.php');

require (DIR_APP_CONFIG . 'config.php');
require (DIR_APP_LIB . 'shared.php');

loadLib('vendor'.DS.'S3');

try {
    $db = Database::getInstance();
} catch (Exception $e) {
    echo $e;
    die();
}

session_start();

ob_start();

define("CLI", !isset($_SERVER['HTTP_USER_AGENT']));

if (!preg_match('/^(.*)\/(login|logout|forgot_password)\.php$/', $_SERVER['PHP_SELF'])) {
    if (CLI === false) {
        if (empty($_SESSION['admin_user'])) {
            $_SESSION['redir'] = $_SERVER['REQUEST_URI'];
            header('Location: login.php', true, 302);
            exit(0);
        }

        $admin_user = $db->query('select * from admin_users where id = '.(int)$_SESSION['admin_user']['id'].' limit 1')->fetch(PDO::FETCH_ASSOC);
        if (!$admin_user || !$admin_user['active']) {
            unset($_SESSION['admin_user']);
            $_SESSION['redir'] = $_SERVER['REQUEST_URI'];
            header('Location: login.php', true, 302);
            exit(0);
        }
    }
}

$required_js = array();
$required_css = array();
