<?php
include("includes/application_top.php");
$page_title = "Participants";

$status = htmlspecialchars($_GET['status']);

if (!empty($_GET['id'])) {
    $user_id = (int) $_GET['id'];

    $user = $db->query("
        SELECT * 
        FROM users u
        JOIN users_details ud ON ud.user_id = u.id
        WHERE u.id = " . $user_id . " 
        LIMIT 1
    ")->fetch(PDO::FETCH_ASSOC);
} else {
    header('location: users.php');
    exit;
}

$return_data = array(
    'errors'     => array(),
    'revalidate' => false
);

$restrictions = array(
    'commenting' => 1,
    'posting'    => 2,
    'voting'     => 3
);

$stats_query = "
    SELECT 
    (
        SELECT COUNT(*)
        FROM `topics`
        WHERE user_id = {$user_id}
    ) AS posts, 
    (
        SELECT COUNT(*)
        FROM `comments`
        WHERE user_id = {$user_id}
    ) AS comments, 
    (
        SELECT (
            SELECT SUM(upvotes)
            FROM `comments`
            WHERE user_id = {$user_id}
        ) + (
            SELECT SUM(upvotes)
            FROM `topics`
            WHERE user_id = {$user_id}
        )
    ) AS upvotes, 
    (
        SELECT (
            SELECT SUM(downvotes)
            FROM `comments`
            WHERE user_id = {$user_id}
        ) + (
            SELECT SUM(downvotes)
            FROM `topics`
            WHERE user_id = {$user_id}
        )
    ) AS downvotes
";
$stats = $db->query($stats_query)->fetch(PDO::FETCH_ASSOC);

/**
 * There are 5 broad areas of the user profile page below the stats:
 *
 * 1: summary of latest 3 things
 * 2: Posts (includes replies, upvotes, downvotes)
 * 3: Comments (includes replies, upvotes, downvotes)
 * 4: Upvotes (topics you upvoted)
 * 5: Flagged (topics or comments flagged)
 *
 * The following SQL queries find all the relevant parts of these.
 */
$summary_topics = $db->query("SELECT 'topic' AS `type`, id AS topic_id, id, title, created_at, upvotes, downvotes, 
(SELECT COUNT(*) FROM comments WHERE comments.topic_id = topics.id) AS `comments`, flagged FROM topics WHERE user_id = {$user_id} ORDER BY CREATED_AT DESC")->fetchAll(PDO::FETCH_ASSOC);

$summary_comments = $db->query("SELECT 'comment' AS `type`, comments.id, comments.id AS parentId, comments.user_id, comments.topic_id, comments.message, comments.flagged, comments.created_at, topics.title, comments.upvotes, comments.downvotes,
(SELECT COUNT(*) FROM comments WHERE comments.parent_comment_id = parentId) AS `comments`
 FROM comments LEFT JOIN topics ON topics.id = comments.topic_id  WHERE comments.user_id = {$user_id} AND parent_comment_id IS NULL ORDER BY comments.created_at DESC")->fetchAll(PDO::FETCH_ASSOC);

$summary_upvotes = $db->query("
    SELECT 
       id AS topic_id, 
       id, 
       title, 
       upvotes, 
       downvotes, 
       created_at, (
          SELECT COUNT(*)
          FROM comments
          WHERE comments.topic_id = topics.id) AS `comments`
    FROM topics
    WHERE id IN (
       SELECT topic_id
       FROM topic_voters
       WHERE user_id = {$user_id} AND upvote = 1
    )
    ORDER BY topics.created_at DESC")->fetchAll(PDO::FETCH_ASSOC);

$summary_downvotes = $db->query("SELECT id as topic_id, id, title, upvotes, downvotes, created_at, 
(SELECT COUNT(*) FROM comments WHERE comments.topic_id = topics.id) AS `comments`
 FROM topics WHERE id IN (SELECT topic_id FROM topic_voters WHERE user_id = {$user_id} AND upvote = 0) ORDER BY topics.created_at DESC")->fetchAll(PDO::FETCH_ASSOC);

$summary_topic_flags = $db->query("SELECT 'topic' AS `type`, id AS parentId, id AS topic_id, id, title, upvotes, downvotes, created_at,
(SELECT COUNT(*) FROM comments WHERE comments.topic_id = parentId) AS `comments`,
COUNT(*) flags
 FROM topics WHERE id IN (SELECT topic_id FROM topic_flags WHERE user_id = {$user_id})
 AND topics.flagged = 1
GROUP BY topic_id 
ORDER BY topics.created_at DESC
 ")->fetchAll(PDO::FETCH_ASSOC);

$summary_comment_flags = $db->query("select 
   'comment' as `type`, 
   comments.id, 
   comments.id as parentId, 
   comments.user_id, 
   comments.topic_id, 
   comments.message, comments.created_at, topics.title, comments.upvotes, comments.downvotes, comments.created_at,
   (select count(*) from comments where comments.parent_comment_id = parentId) as `comments`,
   (select count(*) from comment_flags where comment_flags.comment_id = parentId) as `flags`
from comments 
left join 
   topics on topics.id = comments.topic_id  
where 
   comments.id 
   IN (select comment_id from comment_flags where user_id = {$user_id})
   AND comments.flagged = 1
order by comments.created_at DESC")->fetchAll(PDO::FETCH_ASSOC);

$summary_flags = array_merge($summary_topic_flags, $summary_comment_flags);

if (!is_array($summary_topics))$summary_topics = array();
if (!is_array($summary_comments))$summary_comments = array();
if (!is_array($summary_upvotes))$summary_upvotes = array();

$summary = array_merge($summary_comments, $summary_upvotes, $summary_topics);
usort($summary, function($a, $b) {
    return $b['created_at'] - $a['created_at'];
});
$summary = array_slice($summary, 0, 3);


/*
 * NOTE! This logic has flipped as of 6/6/16.  What was previously "Disallow" is now "Allow".
 */
if (!empty($_POST['posted'])) {

    if (empty($return_data['revalidate']) && empty($return_data['errors'])) {

        $db->query('delete from users_restrictions where user_id = ' . $user['id']);

        foreach(array_values($restrictions) as $restriction) {
            if (!in_array($restriction, $_POST['restrictions'])) {
                $db->perform('users_restrictions', array(
                    'user_id' => $user['id'],
                    'type_id' => $restriction
                ));
            }
        }

        $return_data['redirect'] = 'users_edit.php?id=' . $user['id'];

    }

    echo json_encode($return_data);
    die();
}

switch ($status) {
  case 'active':
    $status_sql = 'active = 1 and archived = 0';
    break;
  case 'inactive':
    $status_sql = 'active = 0 or deleted_at is not null';
    break;
  case 'featured':
    $status_sql = 'featured = 1';
    break;
  case 'flagged':
    $status_sql = 'flagged = 1';
    break;
  case 'archived':
    $status_sql = 'archived = 1';
    break;
  default:
    $status_sql = 'deleted_at is null';
    break;
}

addValidation();
$required_js[] = 'pages/no_validation.js';
$required_js[] = 'pages/participants_profile.js';


$restrictions = array();
$restriction_types = array(
    array('value' => UserModel::DISALLOW_COMMENTS, 'label' => 'Allow commenting'),
    array('value' => UserModel::DISALLOW_TOPICS, 'label' => 'Allow posting topics'),
    array('value' => UserModel::DISALLOW_VOTING, 'label' => 'Allow voting'),
);
foreach($restriction_types as $restriction) {
    $checked = $db
        ->query('select * from users_restrictions where user_id = ' . $user_id . ' and type_id = ' . $restriction['value'])
        ->fetch(PDO::FETCH_ASSOC);

    $restrictions[] = array(
        'value'   => $restriction['value'],
        'label'   => $restriction['label'],
        'checked' => !(bool)$checked,
        'id'      => 'restriction-' . $restriction['value']
    );
}

include("includes/header.php");
?>
<div class="row" id="content-wrapper">
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
        } else if(isset($_GET['successful_ban']) && $_GET['successful_ban'] != 'true') {
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
        <div class="profile-top">

            <h1 class="no-transform profile-heading">
                <?php
                if (strlen($user['screen_name']) > 0) {
                    echo $user['screen_name'] . "'s profile";
                } else {
                    echo 'Profile';
                }
                ?>
            </h1>

            <div class="profile-controls">
                <a href="users.php?login=<?php echo $user['id']; ?>" target="_blank" class="btn btn--white">Login</a>
                <!--
                <a href="users.php?reset=<?php echo $user['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to reset this users password?');" class="btn btn--white">Reset pw</a>
                -->
                <a href="users_edit.php?id=<?php echo $user['id']; ?>" class="btn btn--white">Privileges</a>
                <a href="user_export.php?id=<?php echo $_GET['id']; ?>" class="btn btn--green">Export User</a>
            </div>
        </div>
        
        <?php
        if (count($summary_flags) > 0) {
            $flag = reset($summary_flags);
            $flag['commentid'] = null;
            if ($flag['type'] == 'comment') {
                $flag['commentid'] = $flag['id'];
            }
        ?>
        <div class="row notification notification--alert">
            <div class='col-sm-12 unboxed'>
              <span class="inline-alert">This user has a flagged <?php echo $flag['type']; ?></span>
              <a href="topics_detail.php?id=<?php echo $flag['topic_id']; ?>#comment<?php echo $flag['commentid'];?>" class="notification__options__item notification__options__item--inline">View</a>
            </div>
        </div>
        <?php
        }
        ?>
        
        <div class="row">
            <div class='col-sm-12 stats stats--graphs'>

              <div class="stat">
                <div class="stat__figure"><?php echo (int)$stats['posts']; ?></div>
                <div class="stat__label">POSTS</div>
                <div class="stat__graph"></div>
              </div>

              <div class="stat">
                <div class="stat__figure"><?php echo (int)$stats['comments']; ?></div>
                <div class="stat__label">COMMENTS</div>
                <div class="stat__graph"></div>
              </div>

              <div class="stat">
                <div class="stat__figure"><?php echo (int)$stats['upvotes']; ?></div>
                <div class="stat__label">UPVOTES</div>
                <div class="stat__graph"></div>
              </div>

              <div class="stat">
                <div class="stat__figure"><?php echo (int)$stats['downvotes']; ?></div>
                <div class="stat__label">DOWNVOTES</div>
                <div class="stat__graph"></div>
              </div>

            </div>
        </div>
        
        <div class="row" style="padding: 0 15px;">
            <div class='col-sm-12 tabbed'>

                <div class="tabbed__options">
                    <a href="#" class="tabbed__options__item tabbed__options__item--current" data-tab="tab-content-1">Activity</a>
                    <a href="#" class="tabbed__options__item" data-tab="tab-content-2">Posts</a>
                    <a href="#" class="tabbed__options__item" data-tab="tab-content-3">Comments</a>
                    <a href="#" class="tabbed__options__item" data-tab="tab-content-4">Upvotes</a>
                    <a href="#" class="tabbed__options__item" data-tab="tab-content-5">Downvotes</a>
                    <a href="#" class="tabbed__options__item" data-tab="tab-content-6">Flagged Activity</a>
                </div>

                <div class="tabbed__item tabbed__item--current" id="tab-content-1">
                    <div class="tabbed-content">
                        <?php
                        foreach ($summary as $key => $value) {
                            $substr = 29;
                            $action = "Commented on a topic:";
                            $action = "Commented on a topic:";
                            if ($value['type'] == 'topic') {
                                $substr = 40;
                                $action = "Posted a topic:";
                            } 
                            ?>
                            <div class="tabbed-content__row">
                                <div class="tabbed-content__row__item tabbed-content__row__item--activity <?php if($value['flagged'] == 1) { echo 'add-flag'; } ?>"><?php echo $action;?> <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="deep-blue-link" title="<?php echo $value['title']; ?>"><?php echo trim(substr($value['title'], 0, $substr));?>&hellip;</a></div>
                                <div class="tabbed-content__row__item tabbed-content__row__item--timestamp"><?php echo date('m/d/Y h:iA', $value['created_at']);?></div>
                                <div class="tabbed-content__row__item tabbed-content__row__item--action"><a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="view">View Thread</a></div>
                            </div>    
                            <?php
                        }
                        if (count($summary) == 0) {
                            echo "<p>No recent activity found.</p>";
                        }
                        ?>
                    </div>
                </div>

                <div class="tabbed__item" id="tab-content-2">
                    <div class="tabbed-content">
                        <?php
                        foreach ($summary_topics as $key => $value) {
                            ?>
                          <div class="tabbed-content__row">
                            <div class="tabbed-content__row__item tabbed-content__row__item--post <?php if ($topic['flagged'] == 1) { echo 'add-flag'; } ?>">
                                <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="deep-blue-link" title="<?php echo $value['title'];?>">
                                    <?php echo trim(substr($value['title'], 0, 31));?>&hellip;
                                </a>
                            </div>
                            <div class="tabbed-content__row__item tabbed-content__row__item--timestamp tabbed-content__row__item--timestamp--smaller">
                                <?php echo date('m/d/Y h:iA', $value['created_at']);?>
                            </div>
                            <div class="tabbed-content__row__item"><?php echo (int) $value['comments'];?> Comments</div>
                            <div class="tabbed-content__row__item"><?php echo (int) $value['upvotes'];?> Upvotes</div>
                            <div class="tabbed-content__row__item"><?php echo (int) $value['downvotes'];?> Downvotes</div>
                            <div class="tabbed-content__row__item tabbed-content__row__item--action tabbed-content__row__item--action--smaller">
                                <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="view">
                                    View Thread
                                </a>
                            </div>
                          </div>
                            <?php
                        }
                        if (count($summary_topics) == 0) {
                            echo "<p>No topics posted.</p>";
                        }
                        ?>
                    </div>
                </div>

                <div class="tabbed__item" id="tab-content-3">
                    <div class="tabbed-content">
                        <?php
                        foreach ($summary_comments as $key => $value) {
                        ?>
                              <div class="tabbed-content__row">
                                <div class="tabbed-content__row__item tabbed-content__row__item--post <?php if($topic['flagged'] == 1) { echo 'add-flag'; } ?>">
                                    <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="deep-blue-link" title="<?php echo $value['title'];?>">
                                        <?php echo trim(substr($value['title'], 0, 31));?>&hellip;
                                    </a>
                                </div>
                                <div class="tabbed-content__row__item tabbed-content__row__item--timestamp tabbed-content__row__item--timestamp--smaller">
                                    <?php echo date('m/d/Y h:iA', $value['created_at']);?>
                                </div>
                                <div class="tabbed-content__row__item"><?php echo (int) $value['comments'];?> Replies</div>
                                <div class="tabbed-content__row__item"><?php echo (int) $value['upvotes'];?> Upvotes</div>
                                <div class="tabbed-content__row__item"><?php echo (int) $value['downvotes'];?> Downvotes</div>
                                <div class="tabbed-content__row__item tabbed-content__row__item--action tabbed-content__row__item--action--smaller">
                                    <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>"class="view">View Thread</a>
                                </div>
                              </div>
                        <?php
                        }
                        if (count($summary_comments) == 0) {
                            echo "<p>No comments made.</p>";
                        }
                        ?>
                    </div>
                </div>

                <div class="tabbed__item" id="tab-content-4">
                    <div class="tabbed-content">
                    <?php
                    foreach ($summary_upvotes as $key => $value) {
                    ?>
                      <div class="tabbed-content__row">
                        <div class="tabbed-content__row__item tabbed-content__row__item--post">
                            <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="deep-blue-link" title="<?php echo $value['title'];?>">
                            <?php echo trim(substr($value['title'], 0, 31));?>&hellip;
                            </a>
                        </div>
                        <div class="tabbed-content__row__item tabbed-content__row__item--timestamp tabbed-content__row__item--timestamp--smaller">
                            <?php echo date('m/d/Y h:iA', $value['created_at']);?>
                        </div>
                        <div class="tabbed-content__row__item"><?php echo (int) $value['comments'];?> Comments</div>
                        <div class="tabbed-content__row__item"><?php echo (int) $value['upvotes'];?> Upvotes</div>
                        <div class="tabbed-content__row__item"><?php echo (int) $value['downvotes'];?> Downvotes</div>
                        <div class="tabbed-content__row__item tabbed-content__row__item--action tabbed-content__row__item--action--smaller">
                            <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>"class="view">View Thread</a>
                        </div>
                      </div>
                    <?php
                    }
                    if (count($summary_upvotes) == 0) {
                        echo "<p>No upvotes registered.</p>";
                    }
                    ?>
                    </div>
                </div>


                <div class="tabbed__item" id="tab-content-5">
                    <div class="tabbed-content">
                    <?php
                    foreach ($summary_downvotes as $key => $value) {
                    ?>
                      <div class="tabbed-content__row">
                        <div class="tabbed-content__row__item tabbed-content__row__item--post">
                            <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="deep-blue-link" title="<?php echo $value['title'];?>">
                            <?php echo trim(substr($value['title'], 0, 31));?>&hellip;
                            </a>
                        </div>
                        <div class="tabbed-content__row__item tabbed-content__row__item--timestamp tabbed-content__row__item--timestamp--smaller">
                            <?php echo date('m/d/Y h:iA', $value['created_at']);?>
                        </div>
                        <div class="tabbed-content__row__item"><?php echo (int) $value['comments'];?> Comments</div>
                        <div class="tabbed-content__row__item"><?php echo (int) $value['upvotes'];?> Upvotes</div>
                        <div class="tabbed-content__row__item"><?php echo (int) $value['downvotes'];?> Downvotes</div>
                        <div class="tabbed-content__row__item tabbed-content__row__item--action tabbed-content__row__item--action--smaller">
                            <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>"class="view">View Thread</a>
                        </div>
                      </div>
                    <?php
                    }
                    if (count($summary_downvotes) == 0) {
                        echo "<p>No downvotes registered.</p>";
                    }
                    ?>
                    </div>
                </div>

                <div class="tabbed__item" id="tab-content-6">
                    <div class="tabbed-content">
                    <?php                    
                    foreach ($summary_flags as $key => $value) {
                        if ($value['type'] == 'comment') {
                            $hash = "#comment".$value['id'];
                        } else {
                            $hash = "";
                        }
                    ?>
                      <div class="tabbed-content__row">
                        <div class="tabbed-content__row__item tabbed-content__row__item--post">
                            <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'];?>" class="deep-blue-link" title="<?php echo $value['title'];?>">
                                <?php echo trim(substr($value['title'], 0, 31));?>&hellip;
                            </a>
                        </div>
                        <div class="tabbed-content__row__item tabbed-content__row__item--timestamp tabbed-content__row__item--timestamp--smaller">
                            <?php echo date('m/d/Y h:iA', $value['created_at']);?>
                        </div>
                        <div class="tabbed-content__row__item">
                            <?php echo $value['flags'];?> Flag<?php echo ($value['flags']>1)?"s":"";?>
                        </div>
                        <div class="tabbed-content__row__item tabbed-content__row__item--action tabbed-content__row__item--action--larger">
                            <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'].$hash;?>"class="view">View <?php echo ucwords($value['type']);?></a>
                            <a href="unflag.php?type=<?php echo $value['type'];?>&id=<?php echo $value['id'];?>&return_to=user_profile.php%3Fid%3D<?php echo $_GET['id'];?>" class="view">Un-Flag</a>
                        </div>
                      </div>
                    <?php
                    }
                    if (count($summary_flags) == 0) {
                        echo "<p>No flagged comments or topics.</p>";
                    }
                    ?>
                    </div>
                </div>

            </div>
        </div>

    </div>
</div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
