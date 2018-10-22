<?php
include("includes/application_top.php");

$type = $_GET['type'];
$id = $_GET['id'];
$return_to = $_GET['return_to'];
$flag = $_GET['flag'];
$flagged = 0;

if ($flag == 1) {
	$flagged = 1;
}


if ($type == 'topic') {
    $db->perform("topics", array('active' => $flagged), "update", "id = ".(int)$id." limit 1");
}
if ($type == 'comment') {
    $db->perform("comments", array('active' => $flagged), "update", "id = ".(int)$id." limit 1");
}
header('location: /cmsadmin/'.urldecode($return_to));
exit;
