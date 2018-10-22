<?php
include("includes/application_top.php");

$sort = htmlspecialchars($_GET['sort']);
$search = htmlspecialchars($_GET['search']);
$order = ($_GET['order'] == 'desc'?'desc':'asc');

if(!empty($_GET['delete'])) {
    $category = $db->query('select * from topic_categories where id = ' . $db->quote($_GET['delete']) . ' limit 1')->fetch(PDO::FETCH_ASSOC);
    if($category) {
      TopicCategoryModel::delete($category['id']);
    }
    header("Location: topic_categories.php?successful_delete=true");
    exit();
}

if ($_POST['items']) {
  foreach ((array)$_POST['items'] as $item_i => $item_id) {
    $db->query('update slides set sort_order = '.(int)($item_i + 1).' where id = '.(int)$item_id.' limit 1');
  }
  die();
}

addSortableTable();
include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">

<?php
drawHeaderRow(array(
    array(
      'name' => 'Topic Categories',
      'icon' => 'icon-comment',
      'url'  => 'topic_categories.php'
    ),
));
?>

<?php
if($_GET['successful_delete']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> Category Removed!</h4>
                      Category successfully removed
                    </div>
                  </div>
              </div>


<?php
}
?>            <div class='row'>
                <div class='col-sm-12'>
                  <div class='box'>
                    <div class='box-content'>
                      <a class="btn btn-success" href="topic_categories_edit.php"><i class='icon-plus-sign'> Add new Topic Category</i></a>
                    </div>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-sm-12">
                  <div class="box bordered-box purple-border no-bottom-margin">
                    <div class="box-content box-no-padding">
                      <form>
                      <table class="table table-striped no-bottom-margin sortable-table">
                        <thead>
                          <tr>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Status</th>
                            <th></th>
                          </tr>
                        </thead>
                        <tbody>
                          <?php
                          $items = $db->query('select * from topic_categories order by sort_order asc')->fetchAll(PDO::FETCH_ASSOC);
                          foreach ($items as $category) {
                          ?>
                          <tr>
                            <td><?php echo stripslashes($category['name']); ?></td>
                            <td><?php echo stripslashes($category['type']); ?></td>
                            <td>
                              <span class="label label-success">Active</span>
                            </td>
                            <td>
                              <div class="text-right">
                                <a class="btn btn-success btn-xs" href="topic_categories_edit.php?id=<?php echo $category['id']; ?>">
                                  <i class="icon-edit"></i> Edit
                                </a>
                                <a class="btn btn-danger btn-xs" href="?delete=<?php echo $category['id']; ?>" onclick="return confirm('Are you sure you want to delete this category?');">
                                  <i class="icon-remove"></i> Delete
                                </a>
                              </div>
                            </td>
                            <input type="hidden" name="items[]" value="<?php echo $category['id']; ?>">
                          </tr>
                          <?php
                          }
                          ?>
                        </tbody>
                      </table>
                      </form>
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
