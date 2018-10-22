<?php

switch ($_SERVER['HTTP_HOST']) {

    case 'ucsfcommunity.localhost.com':

        define ('SITE_ENVIRONMENT', 'dev');

        ////
        // Database Config
        define('DB_TYPE', 'mysql');
        define('DB_HOST', 'localhost');
        define('DB_PORT', '3306');
        define('DB_USERNAME', '');
        define('DB_PASSWORD', '');
        define('DB_NAME', '');
        define('DB_CHARSET', 'utf8');

        define('PATH_FROM_ROOT', '/');
        define('HTTP_SERVER', 'http://localhost');
        define('HTTPS_SERVER', 'http://localhost');
        define('HTTP_URL_BASE', HTTP_SERVER.PATH_FROM_ROOT);
        define('ENABLE_SSL', false);

        define('ENABLE_MODULE_CACHE', false);

        break;

}

define('HTTPS_URL_BASE', (ENABLE_SSL === true?HTTPS_SERVER.PATH_FROM_ROOT:HTTP_SERVER.PATH_FROM_ROOT));
define('URL_BASE', PATH_FROM_ROOT);

define('awsEnabled', true);
define('awsAccessKey', '');
define('awsSecretKey', '');
define('awsBucketName', '');
define('awsURL', 'http://'.awsBucketName.'.s3.amazonaws.com/');

define('FOLDER_ASSETS', '');
define('FOLDER_IMG', '');
define('FOLDER_FILES', '');

define('URL_ASSETS', URL_BASE . FOLDER_ASSETS . '/');
define('URL_IMG', URL_ASSETS . FOLDER_IMG . '/');
define('URL_FILES', URL_BASE . FOLDER_FILES . '/');

define('EMAIL_FROM_NAME', '');
define('EMAIL_FROM', '');

define('SENDGRID_USERNAME', '');
define('SENDGRID_PASSWORD', '');

define('APP_API_KEY', '');