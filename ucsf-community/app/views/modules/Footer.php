
        <script>var URL_BASE = '<?php echo URL_BASE; ?>';</script>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script>window.jQuery || document.write('<script src="assets/js/vendor/jquery.min.js"><\/script>')</script>
        <script src="<?php echo URL_BASE . FOLDER_ASSETS; ?>/js/plugins.js"></script>
        <script src="<?php echo URL_BASE . FOLDER_ASSETS; ?>/js/main.js"></script>

<?php
$this->outputRequiredJS();
?>

<?php
if (SITE_ENVIRONMENT === 'live') {
?>
        <script>
            (function(b,o,i,l,e,r){b.GoogleAnalyticsObject=l;b[l]||(b[l]=
            function(){(b[l].q=b[l].q||[]).push(arguments)});b[l].l=+new Date;
            e=o.createElement(i);r=o.getElementsByTagName(i)[0];
            e.src='//www.google-analytics.com/analytics.js';
            r.parentNode.insertBefore(e,r)}(window,document,'script','ga'));
            ga('create','UA-XXXXX-X');ga('send','pageview');
        </script>
<?php
}
?>
    </body>
</html>
