<?php
include("includes/application_top.php");
$id = (int) $_GET['id'];
if (empty($id))exit("Please select a valid user to continue;");

$headings = array(
    'Username',
    'Email',
    'Created Date',
    'Updated Date',
    'Restrictions',
    'Banned',
    'Active',
);
$lines = array($headings);
$get_users = $db->query("SELECT * FROM users WHERE id = {$id} ORDER BY created_at DESC")->fetchAll(PDO::FETCH_ASSOC);

foreach($get_users as $user) {

    $get_restrictions = $db->query('select * from users_restrictions where user_id = ' . $user['id'])->fetchAll(PDO::FETCH_ASSOC);
    $restriction = '(';
    foreach($get_restrictions as $key => $restriction_row) {
        switch($restriction_row['type_id']) {
            case UserModel::DISALLOW_COMMENTS:
                $restriction .= 'No Commenting';
                break;
            case UserModel::DISALLOW_TOPICS:
                $restriction .= 'No Topics';
                break;
            case UserModel::DISALLOW_VOTING:
                $restriction .= 'No Voting';
                break;
            case UserModel::NO_RESTRICTION:
            default:
                $restriction .= 'None';
                break;
        }

        if($key < (count($get_restrictions) - 1)) {
            $restriction .= ', ';
        }
    }

    if(empty($get_restrictions)) {
        $restriction .= 'None';
    }
    $restriction .= ')';

    $lines[] = array(
        $user['username'],
        $user['email_address'],
        date('m/d/Y', $user['created_at']),
        date('m/d/Y', $user['updated_at']),
        $restriction,
        $user['banned'] == 1 ? 'yes' : 'no',
        $user['active'] == 1 ? 'yes' : 'no',
    );
}

header("Content-type: application/vnd.ms-excel");
header("Content-disposition:  attachment; filename=users_export.xls");
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