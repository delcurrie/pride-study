<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <title><?php echo $meta->getTitle(); ?></title>
        <meta name="description" content="<?php echo $meta->getDescription(); ?>">
        <meta name="keywords" content="<?php echo $meta->getKeywords(); ?>">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <?php $this->outputRequiredCSS(); ?>
        
        <link rel="stylesheet" href="<?php echo URL_BASE . FOLDER_ASSETS; ?>/css/main.css">
        <script src="<?php echo URL_BASE . FOLDER_ASSETS; ?>/js/vendor/modernizr.js"></script>
    </head>
    <body class="<?php echo ($this->preview_mode ? 'preview_mode' : ''); ?> <?php echo $this->body_classes; ?>">
        <!--[if lt IE 7]>
            <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
        <![endif]-->

