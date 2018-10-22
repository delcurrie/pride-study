<?php
include("includes/application_top.php");

$db = Database::getInstance();
$comments = CommentModel::find();

foreach ($comments as $comment) {
    $parent = $comment->getParent();
    if ($parent) {
        $parent_parent = $parent->getParent();

        if ($parent_parent) {
        	echo 'Deleting comment: ' . $comment->getId() . ' <br>';
            BaseModel::delete($comment->getId(), CommentModel::getTableName());
        }
    }
}

echo 'Done';