<?php

$routes = array(
    '/'                 => array('controller' => 'Home', 'action' => 'showWelcome'),
    '/no-app-warning'   => array('controller' => 'Home', 'action' => 'showNoAppWarning'),
    '/community/topics' => array('controller' => 'Topics'),
    '/community'        => array('controller' => 'Home', 'action' => 'showCommunity'),
    '/ajax'             => array('controller' => 'AJAX'),
    '/account'          => array('controller' => 'Account'),
    '/authenticate'     => array('controller' => 'Home', 'action' => 'authenticate'),
    '/api/1.0'          => array('controller' => 'APIV1'),
    '/api/v1'           => array('controller' => 'APIV1'),
);
