<?php
include('includes/application_top.php');

unset($_SESSION['admin_user']);
header("Location: index.php", true, 301);
exit();
