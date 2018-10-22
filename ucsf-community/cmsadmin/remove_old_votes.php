<?php 

include("includes/application_top.php");

$comment_votes = CommentVoteModel::find();
$topic_votes = TopicVoteModel::find();

foreach ($comment_votes as $vote) {
    if (!$vote->getComment()) {
    	echo 'Removing vote: ' . $vote->getId() . ' <br>';
        CommentVoteModel::delete($vote->getId());
    }
}

foreach ($topic_votes as $vote) {
    if (!$vote->getTopic()) {
    	echo 'Removing vote: ' . $vote->getId() . ' <br>';
        TopicVoteModel::delete($vote->getId());
    }
}

echo 'Done';
