<?php
include("includes/application_top.php");
$page_title = "New Featured Topic";

$mode = 'add';
if (!empty($_GET['id'])) {
    $topic = $db->query("select * from topics where id = ".(int)$_GET['id']." limit 1")->fetch(PDO::FETCH_ASSOC);
    if ($topic) {
        if ($topic['featured'] == 1) {
          $mode = 'edit';
        } else {
          $mode = 'view';
        }

        $user = '';

        if ($topic['user_id']) {
          $sql  = 'select screen_name from users_details where user_id = ' . (int)$topic['user_id'];
          $user = $db->query($sql)->fetchColumn();
        }

        if ($topic['admin_user_id']) {
          $sql  = 'select name as screen_name from admin_users where id = ' . (int)$topic['admin_user_id'];
          $user = $db->query($sql)->fetchColumn();
        }
        
    }
}

$return_data = array(
  'errors'     => array(),
  'revalidate' => false
);

if (!empty($_POST)) {

    if (empty($return_data['revalidate']) && empty($return_data['errors'])) {

        if ($mode == 'view') {
          $data = array(
            'active' => (int)$_POST['active'],
          );
        } else {
          $data = array(
            'title' => $_POST['title'],
            'description' => $_POST['description'],
            'active' => (int)$_POST['active'],
            'featured' => 1,
            'created_at' => time(),
            'user_id' => 0,
            'admin_user_id' => $_SESSION['admin_user']['id']
          );
          if ($mode == 'edit') {
            unset($data['created_at'], $data['admin_user_id'], $data['user_id']);
          }
        }

        if ($mode == 'add') {
            $data['created_at'] = time();
            $db->perform("topics", $data);
            $id = $db->lastInsertId();
        } else {
            $db->perform("topics", $data, "update", "id = ".(int)$topic['id']." limit 1");
            $id = (int)$topic['id'];
        }

        if (!empty($_POST['topic_categories'])) {
          $db->query('delete from topics_to_topic_categories where topic_id = ' . $id);
          foreach ($_POST['topic_categories'] as $category) {
            $db->perform('topics_to_topic_categories', array(
              'topic_id' => $id,
              'topic_category_id' => $category
            ));
          }
        }

        $return_data['redirect'] = 'topics.php';

    }

    echo json_encode($return_data);
    die();

}

addValidation();
addTinyMCE();
$required_js[] = 'pages/topics_edit.js';

$topic_categories = array();
$categories_query = TopicCategoryModel::find(array('active = 1'), null, 'order by type desc');
foreach ($categories_query as $category) {
  $checked = $db->query('select * from topics_to_topic_categories where topic_id = ' . (int)$_GET['id'] . ' and topic_category_id = ' . $category->getId())->fetch(PDO::FETCH_ASSOC);

  $topic_categories[] = array(
    'value'   => $category->getId(),
    'label'   => $category->getName(),
    'checked' => (bool)$checked
  );
}
include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">

              <div class="row">
                <div class="col-sm-12">
                  <div class="box">
                    <div class="row box-wrapper">
                      <form class="form form-horizontal form-striped" action="#" method="get">
                        <?php
                          if ($mode == 'add' || $mode == 'edit') {
                            drawInputBox('text', 'title', 'Title', $topic);
                        ?>

                        <div class="description-wysiwyg textarea">

                        <?php
                            drawTinyMCETextArea('description', ($mode == 'edit'?'Change ':'') . 'Description', $topic);
                        ?>

                        </div>

                        <div class="col-xs-12 categories">
                          <label class="control-label">Categories</label>
                        <?php
                            drawCheckboxes('topic_categories[]', 'Categories', $topic_categories);
                          }
                        ?>
                        </div>

                        <div class="set-active <?php if ($mode == 'view') { echo 'set-active--flush'; }; ?>">

                        <?php
                          drawSelect('active', array(
                              0 => 'No', 1 => 'Yes'
                          ), 'Active', $topic);
                        ?>

                        </div>

                        <div class="form-actions form-actions--flush">
                          <div class="row">
                              <button class="btn btn-success" type="submit">Save</button>
                              <button class="btn btn-default cancel" type="button">Cancel</button>
                          </div>
                        </div>

                      </form>
                    </div>

                    <?php
                          if ($mode == 'view') {
                    ?>

                    <div class="box-content box-no-padding">
                      <table class="table table-responsive">
                        <tr>
                          <td><strong>I want to know about...</strong></td>
                          <td><?php echo $topic['title']; ?></td>
                        </tr>
                        <tr>
                          <td><strong>Why?</strong></td>
                          <td><?php echo $topic['description']; ?></td>
                        </tr>
                        <tr>
                          <td><strong>User</strong></td>
                          <td><?php echo $user; ?></td>
                        </tr>
                        <tr>
                          <td><strong>Created On</strong></td>
                          <td><?php echo date("m/d/Y", $topic['created_at']); ?></td>
                        </tr>
                        <tr>
                          <td><strong>Status</strong></td>
                          <td>
                            <?php if ($topic['archived'] == 1) { ?>
                              <span class="label label-important">Archived</span>
                              <span class="label label-important">Archived</span>
                            <?php } else if ($topic['deleted_at'] > 0){ ?>
                              <span class="label label-important">Deleted</span>
                            <?php } else if ($topic['active'] == 1){ ?>
                              <span class="label label-success">Active</span>
                            <?php } else { ?>
                              <span class="label label-important">Inactive</span>
                            <?php } ?>
                          </td>
                        </tr>
                        <tr>
                          <td><strong>Featured</strong></td>
                          <td><?php echo ($topic['featured'] == 1 ? '<span class="label label-success">Yes</span>' : '<span class="label label-important">No</span>'); ?></td>
                        </tr>
                        <tr>
                          <td><strong>Flagged</strong></td>
                          <td><?php echo ($topic['flagged'] == 1 ? '<span class="label label-important">Yes</span>' : '<span class="label label-success">No</span>'); ?></td>
                        </tr>
                        <tr>
                          <td><strong>Upvotes</strong></td>
                          <td><?php echo $topic['upvotes']; ?></td>
                        </tr>
                        <tr>
                          <td><strong>Downvotes</strong></td>
                          <td><?php echo $topic['downvotes']; ?></td>
                        </tr>
                        <tr>
                          <td><strong>Flag Count</strong></td>
                          <td><?php echo (int)$topic['flag_count']; ?></td>
                        </tr>
                        <tr>
                          <td><strong>Score</strong></td>
                          <td><?php echo $topic['score']; ?></td>
                        </tr>
                      </table>
                    </div>

                    <?php }; ?>
                  </div>
                </div>
              </div>

            </div>
          </div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
