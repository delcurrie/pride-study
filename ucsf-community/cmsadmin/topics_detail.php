<?php
include("includes/application_top.php");
$page_title = "Topics";
$required_js[] = 'pages/topics_detail.js';

$topic_id = (int) $_GET['id'];

$topic = $db->query("
SELECT `topics`.*, users.username
FROM `topics`
left join users on users.id = topics.user_id
WHERE `topics`.id = {$topic_id}
ORDER BY `created_at` DESC
LIMIT 1
")->fetch();

$tags = $db->query("
SELECT tc.id, tc.name 
FROM topics_to_topic_categories tttc
LEFT join topic_categories as tc 
ON tc.id = tttc.topic_category_id
WHERE tttc.topic_id = {$topic_id}
")->fetchAll(PDO::FETCH_ASSOC);

$comments = $db->query("
SELECT `comments`.*, users.username
FROM `comments`
left join users on users.id = comments.user_id
WHERE `comments`.topic_id = {$topic_id}
ORDER BY `comments`.created_at  DESC
")->fetchAll();

$flags = $db->query("
SELECT users.username, users.id, UNIX_TIMESTAMP(topic_flags.created) as created_at
FROM users
LEFT JOIN topic_flags on topic_flags.user_id = users.id
WHERE topic_id = {$topic_id}
")->fetchAll();


include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">
<?php
if ($_GET['type'] == 'comment') {
  $thing = 'Comment';
} else {
  $thing = 'Topic';  
}
if ($_GET['successful_delete']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> <?php echo $thing; ?> Removed!</h4>
                      <?php echo $thing; ?> successfully removed
                    </div>
                  </div>
              </div>
<?php
}
if ($_GET['successful_deactivate']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> <?php echo $thing; ?> Deactivated!</h4>
                      <?php echo $thing; ?> successfully deactivated
                    </div>
                  </div>
              </div>
<?php
}
if ($_GET['successful_activate']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> <?php echo $thing; ?> Activated!</h4>
                      <?php echo $thing; ?> successfully activated
                    </div>
                  </div>
              </div>
<?php
}
if ($_GET['successful_archive']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> <?php echo $thing; ?> Archived!</h4>
                      <?php echo $thing; ?> successfully archived
                    </div>
                  </div>
              </div>
<?php
}
if ($_GET['successful_unarchive']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> <?php echo $thing; ?> Unarchived!</h4>
                      <?php echo $thing; ?> successfully un-archived
                    </div>
                  </div>
              </div>
<?php
}
if ($_GET['successful_remove_flag']) {
?>
              <div class="row notification notification--success">
                <div class='col-sm-12 unboxed'>
                  You have un-flagged this <?php echo strtolower($thing); ?>
                  <a href="#" class="notification-close notification-close--success js-close-notification"></a>
                </div>
              </div>
<?php
}
?>

<?php
if ($_GET['successful_add_flag']) {
?>
              <div class="row notification notification--success">
                <div class='col-sm-12 unboxed'>
                  You have flagged this <?php echo strtolower($thing); ?>
                  <a href="#" class="notification-close notification-close--success js-close-notification"></a>
                </div>
              </div>
<?php
}
if ($topic['flagged']) {
?>

              <div class="row notification notification--alert">
                <div class='col-sm-12 unboxed'>
                  This topic is flagged
                  <div class="notification__options">
                    <a href="deactivate.php?type=topic&id=<?php echo $_GET['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $_GET['id'];?>%26successful_deactivate%3Dtrue" class="notification__options__item">Deactivate</a>
                    <a href="unflag.php?type=topic&id=<?php echo $_GET['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $_GET['id'];?>%26successful_remove_flag%3Dtrue" class="notification__options__item">Un-flag</a>
                  </div>
                </div>
              </div>
<?php
}
?>
              <div class="row">
                <div class='col-sm-12 unboxed stats'>

                  <div class="stat">
                    <div class="stat__figure"><?php echo (int) count($comments); ?></div>
                    <div class="stat__label">Comments</div>
                  </div>

                  <div class="stat">
                    <div class="stat__figure"><?php echo (int) $topic['upvotes']; ?></div>
                    <div class="stat__label">Upvotes</div>
                  </div>

                  <div class="stat">
                    <div class="stat__figure"><?php echo (int) $topic['downvotes']; ?></div>
                    <div class="stat__label">Downvotes</div>
                  </div>

                  <div class="stat">
                    <div class="stat__figure"><?php echo $topic['score']; ?></div>
                    <div class="stat__label"><a href="refresh_topic_scores.php" target="_blank" title="Refresh all topic scores">Score</a></div>
                    <a href="#" class="stat__tooltip js-stat-tooltip">?

                      <div class="stat__tooltip__content js-tooltip-content">
                        The order by which topics are shown in the Community is dictated by the score, which is calculated from the topic's activity (comments, upvotes, downvotes).
                      </div>
                    </a>

                  </div>

                  <div class="stat">
                    <div class="stat__figure stat__figure--negative"><?php 
                    // Admin users flags are not counted in flag total.
                    // So display it as 1 if so.
                    if ($topic['flagged'] && count($flags) == 0) {
                      echo 1;
                    } else {
                      echo count($flags); 
                    }
                    ?></div>
                    <div class="stat__label">Flag Count</div>
                  </div>
                </div>
              </div>

              <div class="row" style="padding: 0 15px;">
                <div class='col-sm-12 tabbed'>

                  <div class="tabbed__options">
                    <a href="#" class="tabbed__options__item tabbed__options__item--current" data-tab="tab-content-1">Thread</a>
                    <a href="#" class="tabbed__options__item" data-tab="tab-content-2">History</a>
                  </div>

                  <div class="tabbed__item tabbed__item--current" id="tab-content-1">

                    <h2 class='topic__title <?php if ($topic['flagged']) { echo 'flagged'; } ?>'><?php echo $topic['title']; ?></h2>

                    <div class="topic__status">
                      <span class="topic__status__current topic__status__current--active">
                          <?php
                            if ($topic['active']) {
                              if ($topic['flagged']) {
                                echo "Flagged";
                              } else {
                                if ($topic['archived']) {
                                  echo "Archived";
                                } else {
                                  echo "Active";
                                }
                              }
                            } else {
                              echo "Inactive";
                            }
                          ?>
                      </span>
                      <div class="topic__status__dropdown">
                        <a href="deactivate.php?type=topic&flag=1&id=<?php echo $topic['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_activate%3Dtrue" class="topic-status-item">
                          Active
                        </a>
                        <a href="deactivate.php?type=topic&id=<?php echo $topic['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_deactivate%3Dtrue" class="topic-status-item">
                          Inactive
                        </a>
                        <a href="archive.php?type=topic&flag=1&id=<?php echo $topic['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_archive%3Dtrue" class="topic-status-item">
                          Archived
                        </a>
                        <a href="archive.php?type=topic&flag=0&id=<?php echo $topic['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_unarchive%3Dtrue" class="topic-status-item">
                          Unarchived
                        </a>
                        <a href="unflag.php?type=topic&flag=1&id=<?php echo $topic['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_add_flag%3Dtrue" class="topic-status-item">
                          Flagged
                        </a>
                        <a href="unflag.php?type=topic&id=<?php echo $topic['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_remove_flag%3Dtrue" class="topic-status-item">
                          Unflagged
                        </a>
                      </div>
                    </div>

                    <div class="topic__meta">
                      Posted by
                      <a href="/cmsadmin/user_profile.php?id=<?php echo $topic['user_id']; ?>" class="link-highlight"><?php echo $topic['username']; ?></a>
                      on <?php echo date("m/d/Y", $topic['created_at']); ?>
                    </div>

                    <div class="topic__description">
                      <?php
                      echo $topic['description'];
                      ?>
                    </div>

                    <div class="topic__tags">
                      <?php
                      if (count($tags) > 0) {
                        echo "Tags: ";
                        $all_tags = '';
                        foreach ($tags as $key => $value) {
                          $all_tags .= $value['name'].", ";
                        }
                        echo trim(trim($all_tags), ',');
                      }
                      ?>
                    </div>

                    <h3 class="comments__title">Comments</h3>

                    <?php
                    // Show root level comments
                    if (empty($comments)) {
                      echo "No comments available";
                    }
                    foreach ($comments as $key => $comment) {
                      if ($comment['parent_comment_id']) continue;

                    ?>
                    <div class="comment" id="comment<?php echo $comment['id'];?>">
                      <div class="comment__summary">
                        Posted by
                        <a href="/cmsadmin/user_profile.php?id=<?php echo $comment['user_id']; ?>" class="link-highlight">
                          <?php echo $comment['username']; ?>
                        </a>
                        on <?php echo date("m/d/Y", $comment['created_at']); ?>
                        | <?php echo (int) $comment['upvotes']; ?> upvote<?php echo ($comment['upvotes']==1)?"":"s"?>
                        | <?php echo (int) $comment['downvotes']; ?> downvote<?php echo ($comment['downvotes']==1)?"":"s"?>
                        |
                          <span class="inline-object">
                            <span class="comment_status comment_status--<?php echo ($comment['active'])?"active":"inactive"; ?>">
                              <?php
                                if ($comment['active']) {
                                  if ($comment['flagged']) {
                                    echo "Flagged";
                                  } else {
                                    if ($comment['archived']) {
                                      echo "Archived";
                                    } else {
                                      echo "Active";
                                    }
                                  }
                                } else {
                                  echo "Inactive";
                                }
                              ?>
                            </span>
                            <div class="status-dropdown">
                              <a href="deactivate.php?type=comment&flag=1&id=<?php echo $comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_activate%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                Active
                              </a>
                              <a href="deactivate.php?type=comment&id=<?php echo $comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_deactivate%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                Inactive
                              </a>
                              <a href="archive.php?type=comment&flag=1&id=<?php echo $comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_archive%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                Archived
                              </a>
                              <a href="archive.php?type=comment&flag=0&id=<?php echo $comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_unarchive%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                Unarchived
                              </a>
                              <a href="unflag.php?type=comment&flag=1&id=<?php echo $comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_add_flag%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                Flagged
                              </a>
                              <a href="unflag.php?type=comment&id=<?php echo $comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_remove_flag%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                Unflagged
                              </a>
                            </div>
                          </span>
                      </div>
                      <div class="comment__detail">
                        <?php echo $comment['message']; ?>
                      </div>
                      <?php

                      foreach ($comments as $child_key => $child_comment) {
                        if ($child_comment['parent_comment_id'] != $comment['id']) continue;
                        ?>
                        <div class="comment" id="comment<?php echo $child_comment['id'];?>">
                          <div class="comment__summary">
                            Posted by
                            <a href="/cmsadmin/user_profile.php?id=<?php echo $child_comment['user_id']; ?>" class="link-highlight">
                              <?php echo $child_comment['username']; ?>
                            </a>
                            on <?php echo date("m/d/Y", $child_comment['created_at']); ?>
                            | <?php echo (int) $child_comment['upvotes']; ?> upvote<?php echo ($child_comment['upvotes']==1)?"":"s"?>
                            | <?php echo (int) $child_comment['downvotes']; ?> downvote<?php echo ($child_comment['downvotes']==1)?"":"s"?>
                            |
                              <span class="inline-object">
                                <span class="comment_status comment_status--<?php echo ($child_comment['active'])?"active":"inactive"; ?>">
                                <?php
                                  if ($child_comment['active']) {
                                    if ($child_comment['flagged']) {
                                      echo "Flagged";
                                    } else {
                                      if ($child_comment['archived']) {
                                        echo "Archived";
                                      } else {
                                        echo "Active";
                                      }
                                    }
                                  } else {
                                    echo "Inactive";
                                  }
                                ?>
                                </span>
                                <div class="status-dropdown">

                                  <a href="deactivate.php?type=comment&flag=1&id=<?php echo $child_comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_activate%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                    Active
                                  </a>
                                  <a href="deactivate.php?type=comment&id=<?php echo $child_comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_deactivate%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                    Inactive
                                  </a>
                                  <a href="archive.php?type=comment&flag=1&id=<?php echo $child_comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_archive%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                    Archived
                                  </a>
                                  <a href="archive.php?type=comment&flag=0&id=<?php echo $child_comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_unarchive%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                    Unarchived
                                  </a>
                                  <a href="unflag.php?type=comment&flag=1&id=<?php echo $child_comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_add_flag%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                    Flagged
                                  </a>
                                  <a href="unflag.php?type=comment&id=<?php echo $child_comment['id'];?>&return_to=topics_detail.php%3Fid%3D<?php echo $topic['id'];?>%26successful_remove_flag%3Dtrue%26type%3Dcomment" class="status-dropdown__item">
                                    Unflagged
                                  </a>
                                </div>
                              </span>
                          </div>
                          <div class="comment__detail">
                            <?php echo $child_comment['message']; ?>
                          </div>
                        </div>
                        <?php
                      }

                      ?>
                    </div>
                    <?php
                    }
                    ?>
                  </div>

                  <div class="tabbed__item" id="tab-content-2">
                    <div class="tabbed-content">
<?php
$history = array();

$history[] = array(
  'date' => $topic['created_at'],
  'date_formatted' => date("m/d/Y g:iA", $topic['created_at']),
  'username' => $topic['username'],
  'userid' => $topic['user_id'],
  'copy' => 'Created by'
);
if (!empty($topic['updated_at'])) {
  $history[] = array(
    'date' => $topic['updated_at'],
    'date_formatted' => date("m/d/Y g:iA", $topic['updated_at']),
    'username' => $topic['username'],
    'userid' => $topic['user_id'],
    'copy' => 'Updated by'
  );
}
if (!empty($topic['deleted_at'])) {
  $history[] = array(
    'date' => $topic['deleted_at'],
    'date_formatted' => date("m/d/Y g:iA", $topic['deleted_at']),
    'username' => $topic['username'],
    'userid' => $topic['user_id'],
    'copy' => 'Deleted by'
  );
}

foreach ($flags as $key => $value) {
  $history[] = array(
    'date' => $value['created_at'],
    'date_formatted' => date("m/d/Y g:iA", $value['created_at']),
    'username' => $value['username'],
    'userid' => $value['id'],
    'copy' => 'Flagged by'
  );
}

usort($history, function($a, $b){
  return $a['date'] - $b['date'];
});
foreach ($history as $key => $log) {
  ?>
                      <div class="tabbed-content__row">
                        <div class="action">
                          <?php echo $log['copy'];?>
                          <a href="/cmsadmin/user_profile.php?id=<?php echo $log['userid']; ?>">
                            <?php 
                              echo $log['username'];
                            ?>
                          </a>
                          <?php 
                              if (empty($log['username'])) {
                                echo "an unknown user.";
                              }
                            ?>
                        </div>
                        <div class="timestamp">
                          <?php echo $log['date_formatted']; ?>
                        </div>
                      </div>
  <?php
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
