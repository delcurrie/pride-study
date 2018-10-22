<?php
include("includes/application_top.php");
echo "<h1>Refreshing all topic scores</h1>";
$topics = TopicModel::find();
foreach($topics as $topic) {
	$score = $topic->calculateScore();
	echo $topic->getTitle() . ' : ' . $score . '<br>';
}

echo 'Done';