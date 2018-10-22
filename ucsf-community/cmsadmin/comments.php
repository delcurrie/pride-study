<?php
include("includes/application_top.php");

$id = false;
if(isset($_GET['id'])) {
  $id = (int)$_GET['id'];
}

$sort = htmlspecialchars($_GET['sort']);
$search = htmlspecialchars($_GET['search']);
$status = htmlspecialchars($_GET['status']);
$order = ($_GET['order'] == 'desc'?'desc':'asc');

switch ($sort) {
  case 'upvotes':
    $sort = 'upvotes';
    $sort_sql = 'c.upvotes '.$order.', id '.$order;
    break;
  case 'downvotes':
    $sort = 'downvotes';
    $sort_sql = 'c.downvotes '.$order.', id '.$order;
    break;
  case 'flags':
    $sort = 'flag_count';
    $sort_sql = 'c.flag_count '.$order.', id '.$order;
    break;
  default;
  case 'created_at':
    $sort_sql = 'c.created_at '.$order;
    break;
}

switch ($status) {
  case 'active':
    $status_sql = 'c.active = 1';
    break;
  case 'flagged':
    $status_sql = 'c.flagged = 1';
    break;
  case 'removed':
    $status_sql = 'c.archived = 1';
    break;
   default:
    $status_sql = '';
    break;
}

if(!empty($_GET['remove'])) {
    $comment = $db->query('select * from comments where id = ' . $db->quote($_GET['remove']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if($comment) {
      CommentModel::delete($comment['id']);
    }
    header("Location: comments.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_removed=true");
    exit();
}

if(!empty($_GET['remove_flag'])) {
    $comment = $db->query('select * from comments where id = ' . (int)$_GET['remove_flag'] . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if($comment) {
      $comment = CommentModel::build($comment);
      $comment->removeFlag();
    }
    header("Location: comments.php?sort=".$sort."&order=".$order."&search=".$search."&status=".$status."&successful_removed_flag=true");
    exit();
}


include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">

<?php

$topic = '';
if(isset($_GET['topic'])) {
  $topic = '(For: ' . TopicModel::findById((int)$_GET['topic'])->getTitle() . ')';
}

drawHeaderRow(array(
    array(
      'name' => 'Comments ' . $topic,
      'icon' => 'icon-comments',
      'url'  => 'comments.php'
    ),
));
?>

<?php
if($_GET['successful_removed']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> Comment Removed!</h4>
                      Comment successfully removed
                    </div>
                  </div>
              </div>
<?php
}
?>     
<?php
if($_GET['successful_removed_flag']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> Flag On Comment Removed!</h4>
                      Flag On Comment successfully removed
                    </div>
                  </div>
              </div>
<?php
}
?>           
              <nav class='navbar navbar-default' role='navigation'>
                <form class='navbar-form' role='search'>
                  <input type="hidden" name="sort" value="<?php echo $sort; ?>" />
                  <input type="hidden" name="order" value="<?php echo $order; ?>" />
                  <div class='navbar-left'>
                    <div class='form-group'>
                      <select name="status" class="form-control">
                        <option value="all">Status: View All</option>
                        <option value="active"<?php echo ($status == 'active'?' selected="selected"':''); ?>>Status: Active</option>
                        <option value="flagged"<?php echo ($status == 'flagged'?' selected="selected"':''); ?>>Status: Flagged</option>
                        <option value="removed"<?php echo ($status == 'removed'?' selected="selected"':''); ?>>Status: Inactive</option>
                      </select>
                    </div>
                    <div class='form-group'>
                      <input class='form-control' name='search' placeholder='Search' type='text' value='<?php echo htmlspecialchars($search); ?>'>
                    </div>
                    <button class='btn btn-default' type='submit'>Submit</button>
                  </div>
                </form>
              </nav>

              <div class="row">
                <div class="col-sm-12">
                  <div class="box bordered-box purple-border no-bottom-margin">
                    <div class="box-content box-no-padding">
                      <table class="table table-striped no-bottom-margin" style="table-layout: fixed;">
                        <thead>
                          <tr>
                            <th style="word-break: break-all; word-wrap: break-word;">Topic</th>
                            <th style="word-break: break-all; word-wrap: break-word;">Comment</th>
                            <th width="200px" style="word-break: break-all; word-wrap: break-word;">Reply</th>
                            <th style="word-break: break-all; word-wrap: break-word;">User</th>
                            <th style="word-break: break-all; word-wrap: break-word;">Created On</th>
                            <th style="word-break: break-all; word-wrap: break-word;"><a href="?sort=upvotes&order=<?php echo ($sort == 'upvotes' && $order == 'asc'?'desc':'asc'); ?>&search=<?php echo $search; ?>"<?php echo ($sort == 'upvotes'?' style="text-decoration: underline;"':''); ?>>Upvotes</a></th>
                            <th style="word-break: break-all; word-wrap: break-word;"><a href="?sort=downvotes&order=<?php echo ($sort == 'downvotes' && $order == 'asc'?'desc':'asc'); ?>&search=<?php echo $search; ?>"<?php echo ($sort == 'downvotes'?' style="text-decoration: underline;"':''); ?>>Downvotes</a></th>
                            <th style="word-break: break-all; word-wrap: break-word;"><a href="?sort=flags&order=<?php echo ($sort == 'flags' && $order == 'asc'?'desc':'asc'); ?>&search=<?php echo $search; ?>"<?php echo ($sort == 'flags'?' style="text-decoration: underline;"':''); ?>>Flags</a></th>
                            <th style="word-break: break-all; word-wrap: break-word;">Status</th>
                            <th style="word-break: break-all; word-wrap: break-word;"></th>
                          </tr>
                        </thead>
                        <tbody>
<?php
$per_page = 50;
$page = (int)$_GET['page'];
if (empty($page))
    $page = 1;
$start = (($per_page * $page) - $per_page);

$where = array();
$where[] = 'c.id > 0';
if($id) {
  $where[] = 'c.id = ' . $id;
} else {
  if (!empty($search)) {
    $where[] = '(c.message like '.$db->quote('%'.$search.'%').')';
  }
  if (!empty($status_sql)) {
      $where[] = $status_sql;
  }

  if(isset($_GET['topic'])) {
    $where[] = 'c.topic_id = ' . (int)$_GET['topic'];
  }
}

$where = implode(' and ', $where);
$items = $db->query("select c.*, u.username from comments c join users u on c.user_id = u.id where c.parent_comment_id is null and ".$where." order by ".$sort_sql." limit ".$start.', '.$per_page)->fetchAll(PDO::FETCH_ASSOC);
$total_items = $db->query('select count(*) from comments c join users u on c.user_id = u.id where c.parent_comment_id is null and '.$where)->fetchColumn();
$total_pages = ceil($total_items / $per_page);

$params = 'sort='.$sort.'&order='.$order.'&search='.$search.'&status='.$status.'&page='.$page;
foreach ($items as $comment) {
  $topic = $db->query('select * from topics where id = ' . $comment['topic_id'] . ' limit 1')->fetch(PDO::FETCH_ASSOC);
  $replies = $db->query('select * from comments where parent_comment_id = ' . $comment['id'])->fetchAll(PDO::FETCH_ASSOC);
?>
                          <tr>
                            <td style="word-break: break-all; word-wrap: break-word; max-width: 300px;"><?php echo $topic['title']; ?></td>
                            <td style="word-break: break-all; word-wrap: break-word; max-width: 300px;"><?php echo stripslashes($comment['message']); ?></td>
                            <td style="word-break: break-all; word-wrap: break-word; max-width: 300px;">
                              <ul>
                                <?php foreach($replies as $reply) : ?>
                                    <li><?php echo $reply['message']; ?></li>
                                <?php endforeach; ?>
                              </ul>
                            </td>
                            <td style="word-break: break-all; word-wrap: break-word;"><?php echo stripslashes($comment['username']); ?></td>
                            <td style="word-break: break-all; word-wrap: break-word;"><?php echo date("m/d/Y", $comment['created_at']); ?></td>
                            <td style="word-break: break-all; word-wrap: break-word;"><?php echo stripslashes($comment['upvotes']); ?></td>
                            <td style="word-break: break-all; word-wrap: break-word;"><?php echo stripslashes($comment['downvotes']); ?></td>
                            <td style="word-break: break-all; word-wrap: break-word;"><?php echo stripslashes($comment['flag_count']); ?></td>
                            <td style="word-break: break-all; word-wrap: break-word;">
                            <?php if($comment['active'] == 1) { ?>
                              <span class="label label-success">Active</span>
                            <?php } else { ?>
                              <span class="label label-important">Inactive</span>
                            <?php } ?>
                            </td>
                            <td style="word-break: break-all; word-wrap: break-word;">
                              <div class="text-right">
                              <?php if($comment['flagged'] == 1) { ?> 
                                <a class="btn btn-warning btn-xs" href="?remove_flag=<?php echo $comment['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to remove the flag on this comment?');">
                                  <i class="icon-remove"></i> Un-Flag
                                </a>
                              <?php } ?>
                              <?php if($comment['archived'] != 1) { ?> 
                                <a class="btn btn-danger btn-xs" href="?remove=<?php echo $comment['id']; ?>&<?php echo $params; ?>" onclick="return confirm('Are you sure you want to deactivate this comment?');">
                                  <i class="icon-remove"></i> Deactivate
                                </a>
                              <?php } ?>
                              </div>
                            </td>
                          </tr>
<?php
}
?>
                        </tbody>
                      </table>
                    </div>
                  </div>
                  <ul class='pagination pagination-sm'>
<?php
$url = 'comments.php?sort='.$sort.'&order='.$order.'&search='.$search.'&status='.$status.'&page=';

$prev = max(1, $page - 1);
?>
                    <li>
                      <a href='<?php echo $url, $prev; ?>'>«</a>
                    </li>
<?php
for ($i = 1; $i <= $total_pages; $i++) {
?>
                    <li<?php echo ($i == $page?" class='active'":''); ?>>
                      <a href='<?php echo $url, $i; ?>'><?php echo $i; ?></a>
                    </li>
<?php
}
$next = min($total_pages, $page + 1);
?>
                    <li>
                      <a href='<?php echo $url, $next; ?>'>»</a>
                    </li>
                  </ul>
                </div>
              </div>

            </div>
          </div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
