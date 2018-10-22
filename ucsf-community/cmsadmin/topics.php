<?php
include("includes/application_top.php");

$page_title = "Topics";

if (!empty($_GET['delete'])) {
    $topic = $db->query('select * from topics where id = ' . $db->quote($_GET['delete']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if ($topic) {
      TopicModel::delete($topic['id']);
    }
    header("Location: topics.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_delete=true");
    exit();
}

if (!empty($_GET['deactivate'])) {
    $topic = $db->query('select * from topics where id = ' . $db->quote($_GET['deactivate']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if ($topic) {
      TopicModel::deactivate($topic['id']);
    }
    header("Location: topics.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_deactivate=true");
    exit();
}

if (!empty($_GET['activate'])) {
    $topic = $db->query('select * from topics where id = ' . $db->quote($_GET['activate']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if ($topic) {
      TopicModel::activate($topic['id']);
    }
    header("Location: topics.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_activate=true");
    exit();
}

if (!empty($_GET['archive'])) {
    $topic = $db->query('select * from topics where id = ' . $db->quote($_GET['archive']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if ($topic) {
      TopicModel::archive($topic['id']);
    }
    header("Location: topics.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_archive=true");
    exit();
}

if (!empty($_GET['remove_flag'])) {
    $topic = $db->query('select * from topics where id = ' . $db->quote($_GET['remove_flag']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if ($topic) {
      $topic = TopicModel::build($topic);
      $topic->removeFlag();
    }
    header("Location: topics.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_remove_flag=true");
    exit();
}

$sort = htmlspecialchars($_GET['sort']);
$search = htmlspecialchars($_GET['search']);
$status = htmlspecialchars($_GET['status']);

$order = ($_GET['order'] == 'asc'?'asc':'desc');

switch ($sort) {
  case 'title':
    $sort = 'title';
    $sort_sql = 'topics.title '.$order.', topics.id '.$order;
    break;
  case 'created_at':
  default;
    $sort_sql = 'topics.created_at '.$order;
    break;
}

switch ($status) {
  case 'active':
    $status_sql = 'topics.active = 1 AND topics.archived = 0';
    break;
  case 'inactive':
    $status_sql = 'topics.active = 0 OR topics.deleted_at is not null';
    break;
  case 'featured':
    $status_sql = 'topics.featured = 1';
    break;
  case 'flagged':
    $status_sql = 'topics.flagged = 1';
    break;
  case 'archived':
    $status_sql = 'topics.archived = 1';
    break;
  default:
    $status_sql = 'topics.deleted_at IS NULL';
    break;
}

$per_page = 50;
$page = (int)$_GET['page'];
if (empty($page))
    $page = 1;
$start = (($per_page * $page) - $per_page);

$where = array();
$where[] = 'topics.id > 0';
if (!empty($search)) {
    $where[] = '(title LIKE '.$db->quote('%'.$search.'%').' OR description LIKE '.$db->quote('%'.$search.'%').')';
}
if (!empty($status_sql)) {
    $where[] = $status_sql;
}

$where = implode(' and ', $where);

// Filters
$health = (int) $_GET['health'];
$identity = (int) $_GET['identity'];
$age = (int) $_GET['age'];
$status = (int) $_GET['status'];
$flagged = (int) $_GET['flagged'];


if (!empty($sort)) $searching = true;
if (!empty($search)) $searching = true;
if (!empty($health)) $searching = true;
if (!empty($identity)) $searching = true;
if (!empty($age)) $searching = true;
if (array_key_exists('status', $_GET)) $searching = true;
if (array_key_exists('flagged', $_GET)) $searching = true;


$leftJoin = ' LEFT JOIN topics_to_topic_categories ON topics_to_topic_categories.topic_id = topics.id ';
if (!empty($health) && $health > 0) {
  $leftJoin .= " LEFT JOIN topics_to_topic_categories tttc_health ON tttc_health.topic_id = topics.id ";
  $where .= " AND tttc_health.topic_category_id = ".$health;
}
if (!empty($identity) && $identity > 0) {
  $leftJoin .= " LEFT JOIN topics_to_topic_categories tttc_identity ON tttc_identity.topic_id = topics.id ";
  $where .= " AND tttc_identity.topic_category_id = ".$identity;
}
if (!empty($age) && $age > 0) {
  $leftJoin .= " LEFT JOIN topics_to_topic_categories tttc_age ON tttc_age.topic_id = topics.id ";
  $where .= " AND tttc_age.topic_category_id = ".$age;
}
if (array_key_exists('status', $_GET)) {
  $where .= " AND topics.active = ".$status;
}
if (array_key_exists('flagged', $_GET)) {
  $where .= " AND topics.flagged = ".$flagged;
}

$query = "
SELECT `topics`.*
FROM topics
{$leftJoin}
WHERE {$where}
GROUP BY topics.id
ORDER BY {$sort_sql}
LIMIT {$start}, {$per_page}";

$items = $db->query($query);

$count_query  = "
SELECT `topics`.`id`
FROM topics
{$leftJoin}
WHERE ".$where."
GROUP BY topics.id
ORDER BY ".$sort_sql;


$total_items = count($db->query($count_query)->fetchAll());
$total_pages = ceil($total_items / $per_page);

$params = 'sort='.$sort.'&order='.$order.'&search='.$search.'&status='.$status.'&page='.$page;

$categories = $db->query('select * from topic_categories where active = 1 order by type, name')->fetchAll();

// Get the featured topics.
// If the user_id is 0, that means it was last edited by
// an admin user, so get their name instead of the username.
$featured = $db->query("
SELECT `topics`.*,
  IF (`topics`.user_id = 0,
    (
      SELECT name
      FROM admin_users
      WHERE id = `topics`.`admin_user_id`
      LIMIT 1
    ),
    (
      SELECT username
      FROM users
      WHERE users.id = `topics`.`user_id`
      LIMIT 1
    )
  ) AS username
FROM `topics`
LEFT JOIN `users` ON users.id = topics.user_id
WHERE topics.featured = 1
ORDER BY `created_at` DESC
")->fetchAll();


$required_js[] = 'filters.js';

include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">
<?php
if ($_GET['successful_delete']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> Topic Removed!</h4>
                      Topic successfully removed
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
                      <h4><i class='icon-ok-sign'></i> Topic Deactivated!</h4>
                      Topic successfully deactivated
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
                      <h4><i class='icon-ok-sign'></i> Topic Activated!</h4>
                      Topic successfully activated
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
                      <h4><i class='icon-ok-sign'></i> Topic Archived!</h4>
                      Topic successfully archived
                    </div>
                  </div>
              </div>
<?php
}
if ($_GET['successful_remove_flag']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> Topic Flag Removed!</h4>
                      This topics flag was successfully removed.
                    </div>
                  </div>
              </div>
<?php
}
?>
              <form role="search" action="topics.php" method="get" class="js-search">
                  <input type="hidden" name="sort" value="<?php echo $sort; ?>" />
                  <input type="hidden" name="order" value="<?php echo $order; ?>" />
                  <div class="row">
                      <div class="col-sm-12">
                          <div class="box">
                              <div class="row box-wrapper">
                                  <div class="col-md-4 search-container">
                                      <input class="form-control search js-search-term" name="search" placeholder="Search topics" type="text" value="<?php echo htmlspecialchars($search); ?>">
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
                            <a href="#" class="btn filter-btn js-filter-btn">Filters</a>
                            <a class="btn btn-success btn--bump-right" href="topics_edit.php"><i class='icon-plus-sign'> Add new Featured Topic</i></a>
                              </div>
                          </div>
                      </div>
                  </div>

                  <div class='row filter-options <?php  if (!empty($searching)) echo "filter-options--opened"; ?>'>
                    <div class='col-sm-12 unboxed'>
                        <div class="form-group">
                          <select name="health" id="" class="form-control inline-select inline-select--wide js-search-on-change">
                            <option value="" disabled selected>Health</option>
                            <?php
                            foreach ($categories as $key => $value) {
                              if ($value['type'] == 'health') {
                              ?>
                              <option value="<?php echo $value['id']; ?>"
                                <?php if ($health == $value['id']) echo "selected";?>
                              ><?php echo $value['name'];?></option>
                              <?php
                              }
                            }
                            ?>
                          </select>
                          <select name="identity" id="" class="form-control inline-select inline-select--wide js-search-on-change">
                            <option value="" disabled selected>Identity</option>
                            <?php
                            foreach ($categories as $key => $value) {
                              if ($value['type'] == 'identity') {
                              ?>
                              <option value="<?php echo $value['id']; ?>"
                              <?php if ($identity == $value['id']) echo "selected";?>
                              ><?php echo $value['name'];?></option>
                              <?php
                              }
                            }
                            ?>
                          </select>
                          <select name="age" id="" class="form-control inline-select inline-select--wider inline-select--break-small js-search-on-change ">
                            <option value="" disabled selected>Age</option>
                            <?php
                            foreach ($categories as $key => $value) {
                              if ($value['type'] == 'age') {
                              ?>
                              <option value="<?php echo $value['id']; ?>"
                              <?php if ($age == $value['id']) echo "selected";?>
                              ><?php echo $value['name'];?></option>
                              <?php
                              }
                            }
                            ?>
                          </select>
                          <select name="status" id="" class="form-control inline-select js-search-on-change">
                            <option value="status" disabled <?php if (!array_key_exists('status', $_GET)) echo "selected"; ?>>Status
                            </option>
                            <option value="1"
                              <?php if ($_GET['status'] === '1') echo "selected";?>
                            >Active</option>
                            <option value="0"
                            <?php if ($_GET['status'] === '0') echo "selected";?>
                            >Inactive</option>
                          </select>

                          <select name="flagged" id="" class="form-control inline-select js-search-on-change">
                            <option value="flag" disabled <?php if (!array_key_exists('flagged', $_GET)) echo "selected"; ?>>Flag</option>
                            <option value="0"
                              <?php if ($_GET['flagged'] === '0') echo "selected";?>
                            >No Flag</option>
                            <option value="1"
                              <?php if ($_GET['flagged'] === '1') echo "selected";?>
                            >Flagged</option>
                          </select>

                          <a class="btn btn-success btn--bump-right" href="topics.php"><i class='icon-plus-sign'> Reset Search</i></a>

                        </div>
                    </div>
                  </div>
              </form>
              <?php
              if (!empty($searching)) {
                ?>
              <div class='row search-results-heading'>
                <div class='col-sm-12 unboxed'>
                  <span><?php echo $total_items; ?></span> search result<?php echo ($total_items==1)?"":"s"; ?> for <?php echo (!empty($search))?'<span>"'.$search.'"</span>':" your filter" ;?>
                </div>
              </div>

              <?php
              }

              if (!empty($featured) && empty($searching)) {
              ?>

              <div class="row featured-table" style="clear:both;">
                <div class="col-sm-12">
                  <div class="box bordered-box purple-border no-bottom-margin">
                    <div class="box-content box-no-padding">
                      <table class="table table-striped no-bottom-margin" style="table-layout: fixed;">
                        <thead>
                          <tr>
                            <th>Featured Topic</th>
                            <th>Description</th>
                            <th>Tags</th>
                            <th width="150">Posted By</th>
                            <th width="150">Created On</th>
                            <th width="100">Status</th>
                          </tr>
                        </thead>
                        <tbody>
                          <?php
                          foreach ($featured as $key => $value) {
                            $query = "
SELECT topic_categories.id, topic_categories.name
FROM topics_to_topic_categories
LEFT JOIN topic_categories
ON topic_categories.id = topics_to_topic_categories.topic_category_id
WHERE topics_to_topic_categories.topic_id = {$value['id']}";
                            $cats = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
                          ?>
                            <tr>
                              <td style="word-break: break-all; word-wrap: break-word; max-width: 300px;">
                                <a href="/cmsadmin/topics_detail.php?id=<?php echo $value['id']; ?>" class="link-highlight">
                                  <?php echo $value['title']; ?>
                                  <br>
                                  <a href="topics_edit.php?id=<?php echo $value['id']; ?>">
                                    <em>(edit)</em>
                                  </a>
                                </a>
                              </td>
                              <td style="word-break: break-all; word-wrap: break-word; max-width: 300px;">
                                <?php echo strip_tags($value['description']); ?>
                              </td>
                              <td style="word-break: break-all; word-wrap: break-word;">
                                <ul class="flush-list">
                                  <?php
                                  foreach ($cats as $catkey => $catvalue) {
                                    echo "<li>".$catvalue['name']."</li>";
                                  }
                                  ?>
                                </ul>
                              </td>
                              <td width="150">
                                <?php
                                if ($value['user_id'] == 0) {
                                  ?>
                                <a href="/cmsadmin/admin_user_edit.php?id=<?php echo $value['admin_user_id']; ?>" class="link-highlight">
                                  <?php echo $value['username']; ?>
                                </a>
                                  <?php
                                } else {
                                  ?>
                                <a href="/cmsadmin/user_profile.php?id=<?php echo $value['user_id']; ?>" class="link-highlight">
                                  <?php echo $value['username']; ?>
                                </a>
                                  <?php
                                }
                                ?>
                              </td>
                              <td width="150"><?php echo date("m/d/Y", $value['created_at']); ?></td>
                              <td width="100" ><?php echo ($value['active'])?"Active":"Inactive"; ?></td>
                            </tr>
                            <?php
                          }
                          ?>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>

              <?php
              }
              ?>

              <div class="row">
                <div class="col-sm-12">
                  <div class="box bordered-box purple-border no-bottom-margin">
                    <div class="box-content box-no-padding">
                      <table class="table table-striped no-bottom-margin" style="table-layout: fixed;">
                        <thead>
                          <tr>
                            <th>
                              <a href="?sort=title&order=<?php echo ($sort == 'title' && $order == 'asc'?'desc':'asc'); ?>&search=<?php echo $search; ?>"
                              <?php echo ($sort == 'title'?' style="text-decoration: underline;"':''); ?>>
                                Title
                              </a>
                            </th>
                            <th>Description</th>
                            <th>Tags</th>
                            <th width="150">Posted By</th>
                            <!-- <th>Created On</th> -->
                            <th width="150">
                              <a href="?sort=created_at&order=<?php echo ($sort == 'created_at' && $order == 'asc'?'desc':'asc'); ?>&search=<?php echo $search; ?>"<?php echo ($sort == 'created_at'?' style="text-decoration: underline;"':''); ?>
                              >
                              Created On
                              </a>
                            </th>
                            <th width="100" class="status-td">Status</th>
                          </tr>
                        </thead>
                        <tbody>
<?php
foreach ($items as $topic) {
  if (empty($topic['id'])) continue;
  $user = '';
  $topic['comment_count'] = (int) $db->query('select count(id) from comments where topic_id = ' . (int)$topic['id'])->fetchColumn();

  if ($topic['user_id']) {
    $sql  = 'select screen_name from users_details where user_id = ' . (int)$topic['user_id'];
    $user = $db->query($sql)->fetchColumn();
  }

  if ($topic['admin_user_id']) {
    $sql  = 'select name as screen_name from admin_users where id = ' . (int)$topic['admin_user_id'];
    $user = $db->query($sql)->fetchColumn();
  }

  $categories = $db->query('select tc.* from topics_to_topic_categories tttc join topic_categories tc on tttc.topic_category_id = tc.id where tttc.topic_id = ' . $topic['id'])->fetchAll(PDO::FETCH_ASSOC);
?>
                          <tr>
                            <td style="word-break: break-all; word-wrap: break-word; max-width: 300px;" class="<?php if ($topic['flagged'] == 1) { echo 'flagged'; } ?>">
                              <a href="topics_detail.php?id=<?php echo $topic['id']; ?>" class="link-highlight"><?php echo stripslashes($topic['title']); ?></a>
                              <br>
                              <a href="topics_edit.php?id=<?php echo $topic['id']; ?>">
                                <em>(edit)</em>
                              </a>
                            </td>
                            <td style="word-break: break-all; word-wrap: break-word; max-width: 300px;">
                              <?php echo strip_tags(stripslashes($topic['description'])); ?>
                            </td>
                            <td style="word-break: break-all; word-wrap: break-word;">
                              <ul class="flush-list">
                                <?php foreach($categories as $category) : ?>
                                  <li><?php echo $category['name']; ?></li>
                                <?php endforeach; ?>
                              </ul>
                            </td>
                            <td width="150">
                              <?php
                              if ($topic['user_id'] == 0) {
                                ?>
                                <a href="/cmsadmin/admin_user_edit.php?id=<?php echo $topic['admin_user_id']; ?>" class="link-highlight">
                                <?php echo stripslashes($user); ?>
                                </a>
                                <?php
                              } else {
                                ?>
                                <a href="/cmsadmin/user_profile.php?id=<?php echo $topic['user_id']; ?>" class="link-highlight">
                                <?php echo stripslashes($user); ?>
                                </a>
                                <?php
                              }
                              ?>
                            </td>
                            <!-- <td> --><?php //echo stripslashes($topic['score']); ?><!-- </td> -->
                            <td width="150"><?php echo date("m/d/Y", $topic['created_at']); ?></td>
                            <td width="100">
                              <div class="dropdown">
                                <a href="" class="dropdown-toggle" data-toggle='dropdown'>
                                  <?php if ($topic['archived'] == 1 && $topic['deleted_at'] == 0) { ?>
                                    <span class="label label-important">Archived</span>
                                  <?php } else if ($topic['deleted_at'] > 0){ ?>
                                    <span class="label label-important">Deleted</span>
                                  <?php } else if ($topic['active'] == 1){ ?>
                                    <span class="label label-success">Active</span>
                                  <?php } else { ?>
                                    <span class="label label-important">Inactive</span>
                                  <?php } ?>
                                </a>
                                <ul class='dropdown-menu text-left' style="left: -80px !important;">
                                  <li>
                                    <a href="comments.php?topic=<?php echo $topic['id']; ?>">
                                      <i class="icon-comments"></i> Comments
                                    </a>
                                  </li>
                                  <li>
                                    <?php if ($topic['flagged'] == 1) { ?>
                                      <a href="?remove_flag=<?php echo $topic['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to un-flag this topic?');">
                                        <i class="icon-remove"></i> Un-flag
                                      </a>
                                    <?php } ?>
                                  </li>
                                  <li>
                                    <?php if ($topic['archived'] == 0 && $topic['active']){ ?>
                                      <a href="?archive=<?php echo $topic['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to archive this topic?');">
                                        <i class="icon-remove"></i> Archive
                                      </a>
                                    <?php } ?>
                                  </li>
                                  <li>
                                    <?php if ($topic['featured'] == 1 && $topic['active'] && $topic['comment_count'] < 1){ ?>
                                      <a href="?delete=<?php echo $topic['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to delete this topic?');">
                                        <i class="icon-remove"></i> Delete
                                      </a>
                                    <?php } ?>
                                  </li>
                                  <li>
                                    <?php if ($topic['active'] == 1){ ?>
                                      <a href="?deactivate=<?php echo $topic['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to deactivate this topic?');">
                                        <i class="icon-remove"></i> Deactivate
                                      </a>
                                    <?php } else if ($topic['active'] == 0) {?>
                                      <a href="?activate=<?php echo $topic['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to activate this topic?');">
                                        <i class="icon-remove"></i> Activate
                                      </a>
                                    <?php } ?>
                                  </li>
                                </ul>
                              </div>
                            </td>
                            <!--<td>--><?php //echo ($topic['featured'] == 1 ? '<span class="label label-success">Yes</span>' : '<span class="label label-important">No</span>'); ?><!--</td>-->
                            <!--<td>--><?php //echo ($topic['flagged'] == 1 ? '<span class="label label-important">Yes</span>' : '<span class="label label-success">No</span>'); ?><!--</td>-->
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
                              $url = 'topics.php?sort='.$sort.'&order='.$order.'&search='.$search.'&status='.$status.'&page=';
                              $prev = max(1, $page - 1);
                              $next = min($total_pages, $page + 1);
                              ?>
                              <a href="<?php echo $url, $prev; ?>" class="back">&laquo;</a>
                              <span>Page</span>
                              <input type="text" name="page" class="pager-input" value="<?php echo $page; ?>" />
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
