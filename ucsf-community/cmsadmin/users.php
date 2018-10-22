<?php
include("includes/application_top.php");
$page_title = "Participants";
$status = $_GET['status'];
$sort = htmlspecialchars($_GET['sort']);
$from = strtotime($_GET['from']);
$to = strtotime($_GET['to']);
$search = htmlspecialchars(trim($_GET['search']));
$order = ($_GET['order'] == 'desc'?'desc':'asc');

switch ($sort) {
    case 'created_at':
        $sort_sql = 'u.created_at '.$order;
    break;

    default:
    case 'username':
        $sort = 'username';
        $sort_sql = 'u.username '.$order.', u.id '.$order;
    break;
}

if (count($status) > 0) {
    $status_sql = '(';
    if (in_array("active", $status)) {
        $search_active = true;
        $status_sql .= 'OR u.active = 1 ';
    }
    if (in_array("withdrawn", $status)) {
        $search_withdrawn = true;
        $status_sql .= 'OR u.archived = 1 ';
    }
    if (in_array("banned", $status)) {
        $search_banned = true;
        $status_sql .= 'OR u.banned = 1 ';        
    }
    $status_sql .= ')';
    $status_sql = str_replace("(OR", "(", $status_sql);
}


if (!empty($_GET['reset'])) {
    $user = $db->query('select * from users where id = ' . $db->quote($_GET['reset']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if ($user) {
        $user = UserModel::build($user);
        $user->triggerResetPassword();
    }
    header("Location: users.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_reset=true");
    exit();
}

if (!empty($_GET['login'])) {
    if ($_GET['login'] == 'generic') {
        $user_id = 11717; // ID Of a generic CMS user
    } else {
        $user_id = (int)$_GET['login'];
    }
    
    $user = $db->query('select * from users where id = ' . $db->quote($user_id) . ' limit 1')->fetchColumn();
    if ($user) {
        $user = UserModel::build(array('id' => $user));
        App::logoutUser();
        App::loginUser($user_id, true);
        App::redirect(URL_BASE . 'community');
    }
    
}

if (!empty($_GET['ban'])) {
    $user_id = (int)$_GET['ban'];
    $user = $db->query('select * from users where id = ' . $user_id . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if ($user) {
        $user = UserModel::build($user);
        if ($user->isBanned()) {
            $user->removeBan();
            header("Location: user_profile.php?id=".$user_id);
        } else {
            $user->ban();
            header("Location: user_profile.php?id=".$user_id);
        }
    }
    exit();
}

$per_page = 20;
$page = (int)$_GET['page'];
if (empty($page)) {
    $page = 1;
}
$start = (($per_page * $page) - $per_page);

$where = array();
$where[] = 'u.id > 0';
if (!empty($search)) {
    $where[] = '(u.username like '.$db->quote('%'.$search.'%').' or u.email_address like '.$db->quote('%'.$search.'%').')';
}
if (!empty($status_sql)) {
    $where[] = $status_sql;
}

if ($from > 0) { 
    $where[] = 'u.created_at > ' . $from;
}

if ($to > 0) { 
    $where[] = 'u.created_at < ' . $to;
}

$where = implode(' and ', $where);
$where .= " AND u.username != '' ";

$query = "
    SELECT
        u.id,
        u.username,
        u.email_address,
        u.created_at,
        u.banned,
        u.active,
        u.archived,
        ud.screen_name
    FROM
        users u
    JOIN
        users_details ud
    ON
        ud.user_id = u.id where ".$where."

    ORDER BY
        " . $sort_sql;


// Only add the limit clause when not exporting
if (!array_key_exists("export", $_GET)) {
    $query = $query . " LIMIT {$start}, {$per_page}";
}

$items = $db->query($query);
$total_items = $db->query('select count(u.id) from users u where '.$where)->fetchColumn();
$total_pages = ceil($total_items / $per_page);

$params = 'sort='.$sort.'&order='.$order.'&search='.$search.'&status='.$status.'&page='.$page;

if (array_key_exists("export", $_GET)) {

$headings = array(
    'Username',
    'Screen Name',
    'Email',
    'Created Date',
    'Updated Date',
    'Restrictions',
    'Banned',
    'Active',
);
$lines = array($headings);

    foreach($items as $user) {

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

        if (empty($user['username'])) {
            $user['username'] = "No username";
            continue;
            // non-community members should be excluded
        }
        
        if (empty($user['updated_at'])) {
            $user['updated_at'] = "Never";
        } else {
            $user['updated_at'] = date('m/d/Y', $user['updated_at']);
        }

        $lines[] = array(
            $user['username'],
            $user['screen_name'],
            $user['email_address'],
            date('m/d/Y', $user['created_at']),
            $user['updated_at'],
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
}

include("includes/header.php");
?>
<div class="row js-participants" id="content-wrapper">
    <div class="col-xs-12">

        <?php

        if ($_GET['successful_reset']) {
            ?>
            <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                        <a class="close" data-dismiss="alert" href="#">&times;</a>
                        <h4><i class='icon-ok-sign'></i> Reset!</h4>
                        Password reset successfully
                    </div>
                </div>
            </div>
            <?php
        } elseif ($_GET['successful_ban'] == 'true') {
            ?>
            <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                        <a class="close" data-dismiss="alert" href="#">&times;</a>
                        <h4><i class='icon-ok-sign'></i> Banned!</h4>
                        Ban successful
                    </div>
                </div>
            </div>
            <?php
        } else if (isset($_GET['successful_ban']) && $_GET['successful_ban'] != 'true') {
            ?>
            <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                        <a class="close" data-dismiss="alert" href="#">&times;</a>
                        <h4><i class='icon-ok-sign'></i> No longer Banned!</h4>
                        Ban successfully removed
                    </div>
                </div>
            </div>
            <?php
        }
        ?>
        <form role="search" action="users.php" method="get" class="js-search">
            <input type="hidden" name="sort" value="<?php echo $sort; ?>" />
            <input type="hidden" name="order" value="<?php echo $order; ?>" />
            <div class="row">
                <div class="col-sm-12">
                    <div class="box">
                        <div class="row box-wrapper">
                            <div class="col-md-4 search-container">
                                <input class="form-control search js-search-term" name="search" placeholder="Search participants" type="text" value="<?php echo htmlspecialchars($search); ?>">

                              <?php 
                              if (empty($search)) {
                                ?>
                                <button class="search-button"></button>
                                <?php
                              } else {
                                ?>
                                <button class="search-button search-button--close js-clear-search"></button>
                                <?php
                              }
                              ?>
                            </div>
                             <div class="col-md-2">
                                <div class="pseudo-wrapper">
                                    <div class="pseudo">
                                        <div class="row">
                                            <div class="pull-left">
                                                <span>Status</span>
                                            </div>
                                            <div class="pull-right">
                                                <a href="javascript:;" class="pseudo-expand">
                                                    <img src="assets/images/icons/gray-carrot-down.svg" />
                                                </a>
                                            </div>
                                        </div>
                                        <div class="pseudo-content">
                                            <div class="row item">
                                                <div class="pull-left">
                                                    <input name="status[]" type="checkbox" class="css-checkbox js-search-on-change" id="participants-active" value="active" <?php if ($search_active) echo "checked";?> />
                                                    <label class="css-label grey" for="participants-active">Active</label>
                                                </div>
                                            </div>
                                            <div class="row item">
                                                <div class="pull-left">
                                                    <input name="status[]" type="checkbox" class="css-checkbox js-search-on-change" id="participants-withdrawn" value="withdrawn" <?php if ($search_withdrawn) echo "checked";?> />
                                                    <label class="css-label grey" for="participants-withdrawn">Withdrawn</label>
                                                </div>
                                            </div>
                                            <div class="row item">
                                                <div class="pull-left">
                                                    <input name="status[]" type="checkbox" class="css-checkbox js-search-on-change" id="participants-banned" value="banned" <?php if ($search_banned) echo "checked";?> />
                                                    <label class="css-label grey" for="participants-banned">Banned</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-2">
                                <div class="pseudo-wrapper">
                                    <div class="pseudo">
                                        <div class="row js-join-date">
                                            <div class="pull-left">
                                                <span>Join date</span>
                                            </div>
                                            <div class="pull-right">
                                                <a href="javascript:;">
                                                    <img src="assets/images/icons/gray-carrot-down.svg" />
                                                </a>
                                            </div>
                                        </div>
                                        <div class="pseudo-content">
                                            <div class="row item">
                                                <div class="pull-left">
                                                    <label class="grey" for="participants-active">From</label>
                                                    <div class="date-select">
                                                        <input type="input" class="date-select__input js-date-from" name="from" value="<?php echo $_GET['from'];?>" />
                                                        <a href="#" class="date-select__calendar-trigger js-open-calendar" data-item="from" data-month="<?php
                                                        if (!empty($_GET['from'])) {
                                                            $date = explode("/", $_GET['from']);
                                                            echo $date[0];
                                                        }
                                                        ?>" data-year="<?php echo $date[2]; ?>"></a>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row item">
                                                <div class="pull-left">
                                                    <label class="grey" for="participants-withdrawn">To</label>
                                                    <div class="date-select">
                                                        <input type="input" class="date-select__input js-date-to" name="to" value="<?php echo $_GET['to'];?>" />
                                                        <a href="#" class="date-select__calendar-trigger js-open-calendar" data-item="to" data-month="<?php
                                                        if (!empty($_GET['to'])) {
                                                            $date = explode("/", $_GET['to']);
                                                            echo $date[0];
                                                        }
                                                        ?>" data-year="<?php echo $date[2]; ?>"></a>
                                                    </div>
                                                </div>
                                            </div>


                                            <div class="calendar js-calendar">
                                            </div>

                                        </div>
                                    </div>
                                </div>
                            </div>


                            <div class="profile-controls">
                                <a href="users.php?<?php echo $_SERVER['QUERY_STRING'];?>&export=true" class="btn btn--green">Export List</a>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </form>

        <div class="row">
            <div class="col-sm-12">
                <div class="box bordered-box purple-border no-bottom-margin">
                    <div class="box-content box-no-padding">
                        <table class="table no-bottom-margin">
                            <thead>
                                <tr>
                                    <th>Username</th>
                                    <th>Email</th>
                                    <th>Join Date</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                foreach ($items as $user) {
                                    ?>
                                    <tr>
                                        <td class="blue-label"><a href="user_profile.php?id=<?php echo $user['id']; ?>"><?php
                                            echo stripslashes($user['screen_name']);
                                            if (empty($user['screen_name'])) {
                                                echo "<em>No screen name</em>";
                                            }
                                        ?></a></td>
                                        <td class="blue-label"><a href="user_profile.php?id=<?php echo $user['id']; ?>"><?php echo stripslashes($user['email_address']); ?></a></td>
                                        <td class="standard-label"><?php echo date("m/d/Y", $user['created_at']); ?></td>
                                        <td class="standard-label">
                                            <?php
                                            if (!$user['banned'] && !$user['archived']) {
                                                echo 'Active';
                                            } elseif (!$user['banned'] && $user['archived']) {
                                                echo 'Withdrawn';
                                            } else {
                                                echo 'Banned';
                                            }
                                            ?>
                                        </td>
                                        <td class="green-label">
                                            <ul class="flex-spaced inline-list">
                                                <li>
                                                    <a href="users.php?login=<?php echo $user['id']; ?>" target="_blank">Login</a>
                                                </li>
                                                <li>
                                                    <a href="users_edit.php?id=<?php echo $user['id']; ?>">
                                                        Privileges
                                                    </a>
                                                </li>
                                            </ul>
                                        </td>
                                    </tr>
                                <?php
                                }
                                ?>
                            </tbody>
                        </table>
                    </div>
                </div>
                <form role="search">
                    <div class="pager-wrapper">
                        <div class="pager-container">
                            <?php
                            $url = 'users.php?sort='.$sort.'&order='.$order.'&search='.$search.'&status='.$status.'&page=';
                            $prev = max(1, $page - 1);
                            $next = min($total_pages, $page + 1);
                            ?>
                            <a href="<?php echo $url, $prev; ?>" class="back">&laquo;</a>
                            <span>Page</span>
                            <input type="text" name="page" class="pager-input js-page-number" value="<?php echo $page; ?>" />
                            <span>of </span><span class="pages"><?php echo $total_pages; ?></span>
                            <a href="<?php echo $url, $next; ?>" class="next">&raquo;</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
