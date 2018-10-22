<!DOCTYPE html>
<html>
<head>
    <title>UCSF Community Admin Portal</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <meta content="text/html;charset=utf-8" http-equiv="content-type">
    <!-- / START - page related stylesheets [optional] -->
    <link href="assets/stylesheets/plugins/flags/flags.css" media="all" rel="stylesheet" type="text/css" />
    <?php
    if (!empty($required_css)) {
        foreach ($required_css as $rc) {
            if (strpos($rc, '//') === false) {
                if (strpos($rc, '/') !== 0) {
                    $rc = 'assets/stylesheets/'.$rc;
                }
            }

            ?>
            <link rel="stylesheet" href="<?php echo $rc ?>">
            <?php
        }
    }
    ?>
    <!-- / END - page related stylesheets [optional] -->
    <!-- / bootstrap [required] -->
    <link href="assets/stylesheets/bootstrap/bootstrap.css" media="all" rel="stylesheet" type="text/css" />
    <!-- / some awesome -->
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css" rel="stylesheet" crossorigin="anonymous">
    <!-- / theme file [required] -->
    <link href="assets/stylesheets/refresh-theme.css" media="all" id="color-settings-body-color" rel="stylesheet" type="text/css" />
    <!-- / coloring file [optional] (if you are going to use custom contrast color) -->
    <!-- <link href="assets/stylesheets/theme-colors.css" media="all" rel="stylesheet" type="text/css" /> -->
    <!--[if lt IE 9]>
    <script src="assets/javascripts/ie/html5shiv.js" type="text/javascript"></script>
    <script src="assets/javascripts/ie/respond.min.js" type="text/javascript"></script>
    <![endif]-->
</head>
<body class="contrast-blue <?php echo (defined('BODY_CLASS')?BODY_CLASS:''); ?>">
    <?php
    if (!defined('IS_LOGIN') || IS_LOGIN !== true) {
        ?>
        <header>
            <nav class="navbar navbar-default clearfix">
                <a class="navbar-brand" href="index.php">
                    <img class="icon icon-brand" src="assets/images/icons/community-icon@3x.png">
                    <span>Community<br>Admin Portal</span>
                </a>
                <div class="navbar-all-container">
                    <div class="navbar-title-container">
                        <h1><?php echo $page_title; ?></h1>
                    </div>
                    <div class="navbar-button-container">
                        <a class="" title="Create featured post" href='/cmsadmin/topics_edit.php'>
                            <img class="svg" src="assets/images/icons/nav-new-featured-post.svg">
                        </a>
                        <a class="" title="View Community" href='/cmsadmin/users.php?login=generic' target="_blank">
                            <img class="svg" src="assets/images/icons/nav-view-community.svg">
                        </a>
                        <a class="" title="Log out" href='logout.php'>
                            <img class="svg" src="assets/images/icons/nav-logout.svg">
                        </a>
                    </div>
                </div>
            </nav>
        </header>
        <div id="wrapper" class="clearfix">
            <nav id="main-nav">
                <div class="navigation">
                    <?php
                    $nav = array(
                        array(
                            'name' => 'Dashboard',
                            'icon' => 'icon-dashboard',
                            'url' => 'index.php',
                            'src' => 'assets/images/icons/dashboard-icon.svg',
                        ),
                        array(
                            'name' => 'Participants',
                            'icon' => 'icon-group',
                            'url' => 'users.php',
                            'alias' => 'users_edit.php',
                            'src' => 'assets/images/icons/participants-icon.svg',
                        ),
                        array(
                            'name' => 'Topics',
                            'icon' => 'icon-comment',
                            'url' => 'topics.php',
                            'alias' => 'topics_edit.php',
                            'src' => 'assets/images/icons/topic-icon.svg',
                        ),
                        // array(
                        //     'name' => 'Comments',
                        //     'icon' => 'icon-comments',
                        //     'children' => array(
                        //         array(
                        //             'name' => 'View All',
                        //             'url' => 'comments.php',
                        //             'alias' => 'comments_edit.php',
                        //         ),
                        //         array(
                        //             'name' => 'Export',
                        //             'url' => 'comments_export.php',
                        //         ),
                        //     )
                        // ),
                        // array(
                        //     'name' => 'Welcome Sliders',
                        //     'icon' => 'icon-picture',
                        //     'url' => 'sliders.php',
                        //     'alias' => 'sliders_edit.php',
                        // ),
                        // array(
                        //     'name' => 'FAQs',
                        //     'icon' => 'icon-question',
                        //     'url' => 'faqs.php',
                        //     'alias' => 'faqs_edit.php',
                        // ),
                        array(
                            'name' => 'Admins',
                            'icon' => 'icon-user',
                            'url' => 'admin_users.php',
                            'alias' => 'admin_user_edit.php',
                            'src' => 'assets/images/icons/n-a-v-admin-icon.svg',
                        ),
                    );
                    $nav = new nav($nav);
                    ?>
                </div>
            </nav>
            <section id="content">
                <div class="container">
                    <?php
                }
                ?>
