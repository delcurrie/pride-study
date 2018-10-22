<?php
include("includes/application_top.php");
$headings = array(
    'Title',
    'Description',
    'Categories',
    'User',
    'Score',
    'Upvotes',
    'Downvotes',
    'Flagged',
    'Flag Count',
    'Created Date',
    'Updated Date',
    'Deleted Date',
    'Archived',
    'Featured',
    'Active',
);
$lines = array($headings);
$get_topics = $db->query('SELECT * FROM topics ORDER BY created_at DESC')->fetchAll(PDO::FETCH_ASSOC);

foreach($get_topics as $topic) {
    $user = $db->query('select * from users where id = ' . $db->quote($topic['user_id']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    $sql = 'select tc.* from topics_to_topic_categories ttc join topic_categories tc on ttc.topic_category_id = tc.id where ttc.topic_id = ' . $db->quote($topic['id']);
    $categories_query = $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    
    $categories = '(';
    foreach($categories_query as $category) {
        $categories .= $category['slug'] . ',';
    }
    $categories .= ')';

    $lines[] = array(
        $topic['title'],
        $topic['description'],
        $categories,
        $user['username'],
        $topic['score'],
        $topic['upvotes'],
        $topic['downvotes'],
        $topic['flagged'] == 1 ? 'yes' : 'no',
        $topic['flag_count'],
        date('m/d/Y', $topic['created_at']),
        date('m/d/Y', $topic['updated_at']),
        date('m/d/Y', $topic['deleted_at']),
        $topic['archive'] == 1 ? 'yes' : 'no',
        $topic['featured'] == 1 ? 'yes' : 'no',
        $topic['active'] == 1 ? 'yes' : 'no',
    );
}

header("Content-type: application/vnd.ms-excel");
header("Content-disposition:  attachment; filename=topics_export.xls");
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