<?php
include('includes/application_top.php');

$firstDayOfMonth = strtotime( 'first day of ' . date( 'F Y'));
$firstDayOfLastMonth = strtotime( 'first day of ' . date( 'F Y', strtotime('last month')));
// $firstDayOfMonth = 1470009600;
// $firstDayOfLastMonth = 1464739200;
$daysInMonth = cal_days_in_month(CAL_GREGORIAN, date('n'), date('Y'));

$general_stats = $db->query("
 SELECT
(SELECT COUNT(*) FROM users WHERE active = 1) as participants,
(SELECT COUNT(*) FROM topics WHERE active = 1) as topics,
(SELECT COUNT(*) FROM comments WHERE active = 1) as comments,
(select (select sum(upvotes) from comments where active = 1) + (select sum(upvotes) from topics where active = 1)) as upvotes,
(select (select sum(downvotes) from comments where active = 1) + (select sum(downvotes) from topics where active = 1)) as downvotes,
(select (select count(*) from comments where flagged = 1)+(select count(*) from topics where flagged = 1)) as flagged
")->fetch(PDO::FETCH_ASSOC);

# Users last month
$users_last_month = (int) $db->query("select count(*) from users where created_at > {$firstDayOfLastMonth} AND created_at < {$firstDayOfMonth}")->fetch(PDO::FETCH_COLUMN);

# Comments last month
$comments_last_month =  (int)$db->query("select count(*) from comments where created_at > {$firstDayOfLastMonth} AND created_at < {$firstDayOfMonth}")->fetch(PDO::FETCH_COLUMN);

# Topics last month
$topics_last_month =  (int)$db->query("select count(*) from topics where created_at > {$firstDayOfLastMonth} AND created_at < {$firstDayOfMonth}")->fetch(PDO::FETCH_COLUMN);

# Upvotes last month
$upvotes_last_month =  (int)$db->query("select 
(select sum(upvotes) from topics where created_at > {$firstDayOfLastMonth} AND created_at < {$firstDayOfMonth})+
(select sum(upvotes) from comments where created_at > {$firstDayOfLastMonth} AND created_at < {$firstDayOfMonth}) as total_upvotes")->fetch(PDO::FETCH_COLUMN);

# Downvotes last month
$downvotes_last_month =  (int)$db->query("select 
(select sum(downvotes) from topics where created_at > {$firstDayOfLastMonth} AND created_at < {$firstDayOfMonth})+
(select sum(downvotes) from comments where created_at > {$firstDayOfLastMonth} AND created_at < {$firstDayOfMonth} ) as total_downvotes")->fetch(PDO::FETCH_COLUMN);

# Users this month
$users_this_month =  (int)$db->query("select count(*) from users where created_at > {$firstDayOfMonth} ")->fetch(PDO::FETCH_COLUMN);

# Comments this month
$comments_this_month =  (int)$db->query("select count(*) from comments where created_at > {$firstDayOfMonth} ")->fetch(PDO::FETCH_COLUMN);

# Topics this month
$topics_this_month =  (int)$db->query("select count(*) from topics where created_at > {$firstDayOfMonth} ")->fetch(PDO::FETCH_COLUMN);

# Upvotes this month
$upvotes_this_month = $db->query("select 
(select sum(upvotes) from topics where created_at > {$firstDayOfMonth} )+
(select sum(upvotes) from comments where created_at > {$firstDayOfMonth} ) as total_upvotes")->fetch(PDO::FETCH_COLUMN);

# Downvotes this month
$downvotes_this_month =  (int)$db->query("select 
(select sum(downvotes) from topics where created_at > {$firstDayOfMonth} )+
(select sum(downvotes) from comments where created_at > {$firstDayOfMonth} ) as total_downvotes")->fetch(PDO::FETCH_COLUMN);


$flagged_comments = $db->query("
SELECT `comments`.*, 'comment' AS type, users.username, comments.id AS id, message AS title, UNIX_TIMESTAMP(comment_flags.created) as flagged_date
FROM comments
LEFT JOIN users ON users.id = comments.user_id
LEFT JOIN comment_flags on comment_flags.comment_id = comments.id
WHERE flagged = 1
ORDER BY flagged_date DESC")->fetchAll();

$flagged_topics = $db->query("
SELECT 
  `topics`.*, 'topic' AS type, 
  users.username, 
  topics.id AS topic_id, 
  UNIX_TIMESTAMP(topic_flags.created) as flagged_date,
  topics.admin_user_id,
  admin_users.name
FROM topics
LEFT JOIN users ON users.id = topics.user_id
LEFT JOIN topic_flags on topic_flags.topic_id = topics.id
LEFT JOIN admin_users ON admin_users.id = topics.admin_user_id 
WHERE flagged = 1
ORDER BY flagged_date DESC")->fetchAll();

$flagged = array_merge($flagged_topics, $flagged_comments);
usort($flagged, function($a, $b) {
    return $b['flagged_date'] - $a['flagged_date'];
});

if (array_key_exists("page", $_GET)) {
    $page = (int) $_GET['page'];
    if ($page < 0) $page = 0;
    $ajax = true;
} else {
    $ajax = false;
    $page = 0;
}

$perpage = 4;
$page_count = $page;
$page = $page * $perpage;
$prev_page = $page_count - 1;
$next_page = $page_count + 1;
if ($prev_page < 1) {
  $prev_page = 1;
}

$recent_comments = $db->query("SELECT comments.*, 'comment' AS type, users.username, comments.id AS id, message as title, FROM_UNIXTIME(comments.created_at) AS human FROM comments LEFT JOIN users ON users.id = comments.user_id  ORDER BY comments.created_at DESC LIMIT {$page}, 4")->fetchAll();

$recent_topics = $db->query("
  SELECT 
    topics.*, 'topic' AS type, 
    users.username, 
    topics.id AS topic_id, 
    FROM_UNIXTIME(topics.created_at) AS human, 
    topics.created_at AS created_at,
    topics.admin_user_id,
    admin_users.name
  FROM 
    topics 
  LEFT JOIN users ON users.id = topics.user_id 
  LEFT JOIN admin_users ON admin_users.id = topics.admin_user_id 
  ORDER BY 
    topics.created_at 
  DESC LIMIT {$page}, 4;")->fetchAll();
$recent = array_merge($recent_topics, $recent_comments);
usort($recent, function($a, $b) {
    return $b['created_at'] - $a['created_at'];
});
$recent = array_slice($recent, 0,4);

/**
 * Gets the top 4 commenting and topic posting users.
 * Add together then sort the total comments and topics, so we know
 * who has been most active.
 * With those top 4, find the total topic and comment up/downvotes
 * and comment count.
 */
if (!array_key_exists("range", $_GET)) {
    $time = strtotime("-7 days");
} else {
  if ($_GET['range'] == 'all') {
    $time = 0;
  } else {
    $time = strtotime("-".$_GET['range']." days");
  }
}

$activity_comments = $db->query("
SELECT  comments.id, users.id as user_id, users.username,
        COUNT(comments.user_id) AS magnitude,
        COUNT(comments.user_id) AS `comments`,
        SUM(comments.upvotes) AS `upvotes`,
        SUM(comments.downvotes) AS `downvotes`
FROM comments
LEFT JOIN users ON users.id = comments.user_id
WHERE comments.created_at > {$time}
AND users.id > 0
GROUP BY user_id
ORDER BY magnitude DESC, comments.created_at
LIMIT 6
")->fetchAll();

$activity_topics = $db->query("
SELECT  topics.id, topics.user_id, users.username,
        COUNT(topics.user_id) AS magnitude,
        COUNT(topics.user_id) AS `topics`,
        SUM(topics.upvotes) AS `upvotes`,
        SUM(topics.downvotes) AS `downvotes`
FROM topics
LEFT JOIN users ON users.id = topics.user_id
WHERE topics.created_at > {$time}
AND users.id > 0
GROUP BY user_id
ORDER BY magnitude DESC, topics.created_at
LIMIT 6")->fetchAll();

$activity = array();
foreach ($activity_comments as $key => $value) {
    $activity[] = array(
        'id' => $value['user_id'],
        'username' => $value['username'],
        'upvotes' => $value['upvotes'],
        'downvotes' => $value['downvotes'],
        'topics_comments' => $value['comments'],
        'activity' => $value['magnitude']
  );
}
foreach ($activity_topics as $key => $value) {
    $existing = null;
    foreach ($activity as $actkey => $actval) {
        if ($actval['id'] == $value['user_id']) {
            $existing = $actkey;
        }
    }
    if ($existing !== null) {
      $activity[$existing]['magnitude'] = $activity[$existing]['magnitude'] + $value['magnitude'];
      $activity[$existing]['topics_comments'] = $activity[$existing]['topics_comments'] + $value['topics'];

    } else {
      $activity[] = array(
          'id' => $value['user_id'],
          'username' => $value['username'],
          'upvotes' => $value['upvotes'],
          'downvotes' => $value['downvotes'],
          'topics_comments' => $value['topics'],
          'activity' => $value['magnitude']
      );
    }
}
$activity = array_slice($activity, 0,6);


// Get data for graphs
$month_topics = $db->query("SELECT id, upvotes, downvotes, DAY(FROM_UNIXTIME(created_at)) as dayOfMonth, MONTH(FROM_UNIXTIME(created_at)) as month, created_at FROM topics WHERE created_at > {$firstDayOfMonth} ORDER BY created_at ASC LIMIT 5000")->fetchAll();

$month_users = $db->query("SELECT id, DAY(FROM_UNIXTIME(created_at)) as dayOfMonth, MONTH(FROM_UNIXTIME(created_at)) as month, created_at FROM users WHERE created_at > $firstDayOfMonth ORDER BY created_at ASC LIMIT 5000")->fetchAll();

$month_comments = $db->query("SELECT id, upvotes, downvotes, DAY(FROM_UNIXTIME(created_at)) as dayOfMonth, MONTH(FROM_UNIXTIME(created_at)) as month, created_at FROM comments WHERE created_at > $firstDayOfMonth ORDER BY created_at ASC LIMIT 5000")->fetchAll();

$month_topic_votes = $db->query("SELECT id, upvote, DAY(FROM_UNIXTIME(created_at)) as dayOfMonth, MONTH(FROM_UNIXTIME(created_at)) as month, created_at FROM topic_voters WHERE created_at > {$firstDayOfMonth} ORDER BY created_at ASC LIMIT 5000")->fetchAll();

$month_comment_votes = $db->query("SELECT id, upvote, DAY(FROM_UNIXTIME(created_at)) as dayOfMonth, MONTH(FROM_UNIXTIME(created_at)) as month, created_at FROM comment_voters WHERE created_at > {$firstDayOfMonth} ORDER BY created_at ASC LIMIT 5000")->fetchAll();

$month_votes = array_merge($month_comment_votes, $month_topic_votes);

$stats = array();

$labels = "";
for ($i = 1; $i <= $daysInMonth; $i++) {
  $labels .= '"'.$i.' '.date('M').'",';
  $stats[$i]['users'] = 0;
  $stats[$i]['comments'] = 0;
  $stats[$i]['topics'] = 0;
  $stats[$i]['upvotes'] = 0;
  $stats[$i]['downvotes'] = 0;

  foreach ($month_users as $mkey => $muser) {
    if ($muser['dayOfMonth'] == $i) {    
      $stats[$i]['users']++;      
    }
  }

  foreach ($month_comments as $mkey => $mcomment) {
    if ($mcomment['dayOfMonth'] == $i) {    
      $stats[$i]['comments']++;      
    }
  }

  foreach ($month_topics as $mkey => $mtopic) {
    if ($mtopic['dayOfMonth'] == $i) {    
      $stats[$i]['topics']++;      
    }
  }

  foreach ($month_votes as $mkey => $vote) {
    if ($vote['dayOfMonth'] == $i) {    
      if ($vote['upvote'] == 1) {
        $stats[$i]['upvotes']++;
      } else {
        $stats[$i]['downvotes']++;      
      }
    }
  }
}

$labels = trim($labels, ",");
$users_data = implode(",", array_column($stats, "users"));
$posts_data = implode(",", array_column($stats, "comments"));
$comments_data = implode(",", array_column($stats, "topics"));
$upvotes_data = implode(",", array_column($stats, "upvotes"));
$downvotes_data = implode(",", array_column($stats, "downvotes"));

$chart_users_stats['first_val'] = $stats[1]["users"];
$chart_comments_stats['first_val'] = $stats[1]["comments"];
$chart_topics_stats['first_val'] = $stats[1]["topics"];
$chart_upvotes_stats['first_val'] = $stats[1]["upvotes"];
$chart_downvotes_stats['first_val'] = $stats[1]["downvotes"];

$chart_users_stats['last_val'] = $stats[$daysInMonth]["users"];
$chart_comments_stats['last_val'] = $stats[$daysInMonth]["comments"];
$chart_topics_stats['last_val'] = $stats[$daysInMonth]["topics"];
$chart_upvotes_stats['last_val'] = $stats[$daysInMonth]["upvotes"];
$chart_downvotes_stats['last_val'] = $stats[$daysInMonth]["downvotes"];

if ($users_this_month == 0) {
  $chart_users_stats['percentage'] = -100;
} else {
  if ($users_last_month == 0) {
    $chart_users_stats['percentage'] = 100;
  } else {
    $chart_users_stats['percentage'] = 100-(int)(($users_this_month/$users_last_month)*100);
  }
}

if ($topics_this_month == 0) {
  $chart_topics_stats['percentage'] = -100;
} else {
  if ($topics_last_month == 0) {
    $chart_topics_stats['percentage'] = 100;
  } else {
    $chart_topics_stats['percentage'] = 100-(int)(($topics_this_month/$topics_last_month)*100);
  }
}

if ($comments_this_month == 0) {
  $chart_comments_stats['percentage'] = -100;
} else {
  if ($comments_last_month == 0) {
    $chart_comments_stats['percentage'] = 100;
  } else {
    $chart_comments_stats['percentage'] = 100-(int)(($comments_this_month/$comments_last_month)*100);
  }
}

if ($upvotes_this_month == 0) {
  $chart_upvotes_stats['percentage'] = -100;
} else {
  if ($upvotes_last_month == 0) {
    $chart_upvotes_stats['percentage'] = 100;
  } else {
    $chart_upvotes_stats['percentage'] = 100-(int)(($upvotes_this_month/$upvotes_last_month)*100);
  }
}

if ($downvotes_this_month == 0) {
  $chart_downvotes_stats['percentage'] = -100;
} else {
  if ($downvotes_last_month == 0) {
    $chart_downvotes_stats['percentage'] = 100;
  } else {
    $chart_downvotes_stats['percentage'] = 100-(int)(($downvotes_this_month/$downvotes_last_month)*100);
  }
}

$chart_users_stats['first_month'] = strtoupper(date('M'));
$chart_topics_stats['first_month'] = strtoupper(date('M'));
$chart_comments_stats['first_month'] = strtoupper(date('M'));
$chart_upvotes_stats['first_month'] = strtoupper(date('M'));
$chart_downvotes_stats['first_month'] = strtoupper(date('M'));

if ($users_this_month >= $users_last_month) {
  $chart_users_stats['posneg'] = "positive";
} else {
  $chart_users_stats['posneg'] = "negative";  
}
if ($topics_this_month >= $topics_last_month) {
  $chart_topics_stats['posneg'] = "positive";
} else {
  $chart_topics_stats['posneg'] = "negative";  
}
if ($comments_this_month >= $comments_last_month) {
  $chart_comments_stats['posneg'] = "positive";
} else {
  $chart_comments_stats['posneg'] = "negative";  
}
if ($upvotes_this_month >= $upvotes_last_month) {
  $chart_upvotes_stats['posneg'] = "positive";
} else {
  $chart_upvotes_stats['posneg'] = "negative";  
}
if ($downvotes_this_month >= $downvotes_last_month) {
  $chart_downvotes_stats['posneg'] = "positive";
} else {
  $chart_downvotes_stats['posneg'] = "negative";  
}


$page_title = "Dashboard";
$required_js[] = 'plugins/chart.js/dist/Chart.bundle.min.js';
$required_js[] = 'pages/admin_dashboard.js';
include('includes/header.php');
echo "<script type='text/javascript'>";
echo "var users_labels = [".$labels."];";
echo "var users_data = [".$users_data."];";

echo "var posts_labels = [".$labels."];";
echo "var posts_data = [".$posts_data."];";

echo "var comments_labels = [".$labels."];";
echo "var comments_data = [".$comments_data."];";

echo "var upvotes_labels = [".$labels."];";
echo "var upvotes_data = [".$upvotes_data."];";

echo "var downvotes_labels = [".$labels."];";
echo "var downvotes_data = [".$downvotes_data."];";
echo "</script>";
?>
        <div class='row' id='content-wrapper'>
            <div class='col-xs-12'>

                <div class="module community-statistics">
                    <div class="community-statistics__heading">Community Statistics</div>

                    <div class="stats community-statistics__stats">
                        <div class="stat community-statistics__stats__item">
                            <div class="stat__figure"><?php echo (int)$general_stats['participants']; ?></div>
                            <div class="stat__label">Participants</div>
                            <div class="stat__graph">
                                <canvas class="users_graph" width="150" height="100"></canvas>
                            </div>
                            <div class="stat__graph-key">
                              <div class="graph-key"><?php echo $chart_users_stats['first_month']; ?></div>
                              <div class="graph-stat graph-stat--<?php echo $chart_users_stats['posneg']; ?>" title="Last month: <?php echo $users_last_month;?>. This month: <?php echo $users_this_month;?>"><?php echo $chart_users_stats['percentage']; ?>%</div>
                            </div>
                        </div>

                        <div class="stat community-statistics__stats__item">
                            <div class="stat__figure"><?php echo (int)$general_stats['topics']; ?></div>
                            <div class="stat__label">Posts</div>
                            <div class="stat__graph">
                                <canvas class="posts_graph" width="150" height="100"></canvas>
                            </div>
                            <div class="stat__graph-key">
                              <div class="graph-key"><?php echo $chart_topics_stats['first_month']; ?></div>
                              <div class="graph-stat graph-stat--<?php echo $chart_topics_stats['posneg']; ?>" title="Last month: <?php echo $topics_last_month;?>. This month: <?php echo $topics_this_month;?>"><?php echo $chart_topics_stats['percentage']; ?>%</div>
                            </div>
                        </div>
                        <div class="stat community-statistics__stats__item">
                            <div class="stat__figure"><?php echo (int)$general_stats['comments']; ?></div>
                            <div class="stat__label">Comments</div>
                            <div class="stat__graph">
                                <canvas class="comments_graph" width="150" height="100"></canvas>
                            </div>
                            <div class="stat__graph-key">
                              <div class="graph-key"><?php echo $chart_comments_stats['first_month']; ?></div>
                              <div class="graph-stat graph-stat--<?php echo $chart_comments_stats['posneg']; ?>" title="Last month: <?php echo $comments_last_month;?>. This month: <?php echo $comments_this_month;?>"><?php echo $chart_comments_stats['percentage']; ?>%</div>
                            </div>
                        </div>

                        <div class="stat community-statistics__stats__item">
                            <div class="stat__figure"><?php echo (int)$general_stats['upvotes']; ?></div>
                            <div class="stat__label">Upvotes</div>
                            <div class="stat__graph">
                                <canvas class="upvotes_graph" width="150" height="100"></canvas>
                            </div>
                            <div class="stat__graph-key">
                              <div class="graph-key"><?php echo $chart_upvotes_stats['first_month']; ?></div>
                              <div class="graph-stat graph-stat--<?php echo $chart_upvotes_stats['posneg']; ?>" title="Last month: <?php echo $upvotes_last_month;?>. This month: <?php echo $upvotes_this_month;?>"><?php echo $chart_upvotes_stats['percentage']; ?>%</div>
                            </div>
                        </div>

                        <div class="stat community-statistics__stats__item">
                            <div class="stat__figure"><?php echo (int)$general_stats['downvotes']; ?></div>
                            <div class="stat__label">Downvotes</div>
                            <div class="stat__graph">
                                <canvas class="downvotes_graph" width="150" height="100"></canvas>
                            </div>
                            <div class="stat__graph-key">
                              <div class="graph-key"><?php echo $chart_downvotes_stats['first_month']; ?></div>
                              <div class="graph-stat graph-stat--<?php echo $chart_downvotes_stats['posneg']; ?>" title="Last month: <?php echo $downvotes_last_month;?>. This month: <?php echo $downvotes_this_month;?>"><?php echo $chart_downvotes_stats['percentage']; ?>%</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class='row' id='content-wrapper'>
            <div class='col-xs-12'>
                <div class="module">
                    <div class="module__heading">Flagged Items for review <span class="flagged-items"><?php echo (int)count($flagged); ?></span></div>

                    <div class="module__content">
                        <?php
                        foreach ($flagged as $key => $value) {
                            ?>
                            <div class="module-row">
                                <div class="module-row__item module-row__item--activity">
                                    <?php
                                    if ($value['user_id'] == 0) {
                                    ?>
                                    <a href="/cmsadmin/admin_user_edit.php?id=<?php echo $value['admin_user_id']; ?>" class="user-link"><?php echo $value['name']; ?></a> 
                                    <?php
                                    } else {
                                    ?>
                                    <a href="/cmsadmin/user_profile.php?id=<?php echo $value['user_id']; ?>" class="user-link"><?php echo $value['username']; ?></a> 
                                    <?php
                                    } 
                                    ?>


                                    Posted a <?php echo $value['type']; ?>:
                                    <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id']; ?>" class="post-link">
                                        <?php
                                            echo substr($value['title'], 0, 35);
                                            if (strlen($value['title'])>35) {
                                                echo "&hellip;";
                                            }
                                        ?>

                                    </a></div>
                                <div class="module-row__item module-row__item--timestamp">
                                    <?php
                                      if ($value['flagged_date'] == 0) {
                                        echo "Flagged date not recorded.";
                                      } else {
                                        echo date('m/d/Y h:iA', $value['flagged_date']);
                                      }
                                    ?>
                                </div>
                                <div class="module-row__item module-row__item--actions">
                                    <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id']; ?>" class="view">View Thread</a>
                                    <a href="deactivate.php?type=<?php echo $value['type']; ?>&id=<?php echo $value['id']; ?>&return_to=index.php">Deactivate <?php echo ucwords($value['type']); ?></a>
                                    <a href="unflag.php?type=<?php echo $value['type']; ?>&id=<?php echo $value['id']; ?>&return_to=index.php" class="view">Un-Flag</a>
                                </div>
                            </div>
                            <?php
                        }
                        ?>
                    </div>
                </div>
            </div>
        </div>

        <div class='row clearfix' id='content-wrapper'>
            <div class='col-xs-12'>

                <div class="module module--two-thirds">
                    <div class="module__heading">Recent Activity</div>
                    <div class="module__content">
                        <?php
                        foreach ($recent as $key => $value) {
                            $comment_link = '';
                            if ($value['type'] == 'comment') {
                              $comment_link = '#comment'.$value['id'];
                            }

                            ?>
                            <div class="module-row">
                                 <div class="module-row__item module-row__item--activity">
                                    <?php
                                    if ($value['user_id'] == 0) {
                                    ?>
                                    <a href="/cmsadmin/admin_user_edit.php?id=<?php echo $value['admin_user_id']; ?>" class="user-link"><?php echo $value['name']; ?></a> 
                                    <?php
                                    } else {
                                    ?>
                                    <a href="/cmsadmin/user_profile.php?id=<?php echo $value['user_id']; ?>" class="user-link"><?php echo $value['username']; ?></a> 
                                    <?php                                    
                                    }
                                    ?>
                                    Posted a <?php echo $value['type']; ?>:
                                    <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['topic_id'].$comment_link; ?>" class="post-link">
                                        <?php
                                            echo substr($value['title'], 0, 100);
                                            if (strlen($value['title'])>100) {
                                                echo "&hellip;";
                                            }
                                        ?>

                                    </a></div>
                                <div class="module-row__item module-row__item--last module-row__item--timestamp">
                                    <?php echo date('m/d/Y h:iA', $value['created_at']);?>
                                </div>
                            </div>
                            <?php
                        }
                        ?>
                        <div class="module__footer module__footer--alt">
                            <a href="?page=<?php echo $prev_page ;?>" class="js-recent previous-results <?php if ($next_page > 2) echo 'previous-results--highlight';?>"></a>
                            <a href="?page=<?php echo $next_page ;?>" class="js-recent next-results next-results--highlight"></a>
                        </div>
                    </div>
                </div>

                <div class="module module--one-third">
                    <div class="module__heading">
                        Most Active

                        <div class="time-options">
                            <form action="?" method="get">
                            <select name="range" id="" class="time-select" onchange="this.form.submit();">
                                <option value="7" <?php if ($_GET['range'] == 7) echo "selected"; ?>>Last 7 days</option>
                                <option value="30" <?php if ($_GET['range'] == 30) echo "selected"; ?>>1 Month</option>
                                <option value="90" <?php if ($_GET['range'] == 90) echo "selected"; ?>>3 Months</option>
                                <option value="180" <?php if ($_GET['range'] == 180) echo "selected"; ?>>6 Months</option>
                                <option value="all" <?php if ($_GET['range'] == all) echo "selected"; ?>>All Time</option>
                            </select>
                            </form>
                        </div>
                    </div>

                    <div class="module__content">
                        <?php
                        foreach($activity as $key => &$value) {
                        ?>
                            <div class="module-row module-row--alt">
                                <div class="active-user">
                                    <a href="/cmsadmin/user_profile.php?id=<?php echo $value['id']; ?>" class="user-link">
                                        <?php echo $value['username']; ?>
                                    </a>
                                </div>

                                <div class="active-user-stats">
                                    <div class="active-user-stats__first" title="Upvotes on Comments and Topics">
                                        <span class="stat-positive"></span><?php echo (int) $value['upvotes']; ?>
                                    </div>
                                    <div class="active-user-stats__second" title="Downvotes on Comments and Topics">
                                        <span class="stat-negative"></span><?php echo (int) $value['downvotes']; ?>
                                    </div>
                                    <div class="active-user-stats__third" title="Comments and Topics">
                                        <span class="stat-comments"></span><?php echo (int) $value['topics_comments']; ?>
                                    </div>
                                </div>
                            </div>
                        <?php
                        }
                        if (count($activity) <= 0) {
                            ?>
                            <div class="module-row module-row--alt">
                                No activity found in that date range.
                            </div>
                            <?php
                        }
                        ?>
                    </div>
                </div>
            </div>
        </div>
<?php
include('includes/footer.php');
include('includes/application_bottom.php');
?>
