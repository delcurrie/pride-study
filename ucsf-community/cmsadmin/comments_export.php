<?php
include("includes/application_top.php");
$headings = array(
    'ID',
    'Parent ID',
    'User',
    'Message',
    'Upvotes',
    'Downvotes',
    'Flagged',
    'Flag Count',
    'Created Date',
    'Updated Date',
    'Deleted Date',
    'Archived',
    'Closed',
    'Active',
);
$lines = array($headings);
$comments = $db->query('SELECT * FROM comments ORDER BY created_at DESC')->fetchAll(PDO::FETCH_ASSOC);

foreach($comments as $comment) {
    $user = $db->query('select * from users where id = ' . $db->quote($comment['user_id']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    
    if((int)$comment['parent_comment_id']) {
        $parent = $db->query('select * from comments where id = ' . (int)$comment['parent_comment_id'] . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    }
    
    
    $parent_id = 'No Parent';
    if(isset($parent['id'])) {
        $parent_id = $parent['id'];
    }

    $lines[] = array(
        $comment['id'],
        $parent_id,
        $user['username'],
        $comment['message'],
        $comment['upvotes'],
        $comment['downvotes'],
        $comment['flagged'] == 1 ? 'yes' : 'no',
        $comment['flag_count'],
        date('m/d/Y', $comment['created_at']),
        date('m/d/Y', $comment['updated_at']),
        date('m/d/Y', $comment['deleted_at']),
        $comment['archived'] == 1 ? 'yes' : 'no',
        $comment['closed'] == 1 ? 'yes' : 'no',
        $comment['active'] == 1 ? 'yes' : 'no',
    );
}

header("Content-type: application/vnd.ms-excel");
header("Content-disposition:  attachment; filename=comments_export.xls");
$handle = fopen('php://temp', 'r+');
foreach ($lines as $line) {
    fputcsv($handle, $line, "\t", '"');
}
rewind($handle);
$contents = '';
while (!feof($handle)) {
   $contents .= fread($handle, 8192);
}
fclose($handle);
echo $contents;
die();