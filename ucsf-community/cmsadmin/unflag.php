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
    $db->perform("topics", array('flagged' => $flagged), "update", "id = ".(int)$id." limit 1");
    $db->query('delete from topic_flags where topic_id = ' . (int)$id);
}
if ($type == 'comment') {
    $db->perform("comments", array('flagged' => $flagged), "update", "id = ".(int)$id." limit 1");
    $db->query('delete from comment_flags where comment_id = ' . (int)$id);
}

header('location: /cmsadmin/'.urldecode($return_to));
exit;
