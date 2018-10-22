<?php
include("includes/application_top.php");

if (!empty($_GET['delete'])) {
    $db->query("delete from admin_users where id = ".(int)$_GET['delete']." limit 1");
    header("Location: admin_users.php");
    exit();
}

if ($_POST['items']) {
  foreach ((array)$_POST['items'] as $item_i => $item_id) {
    $db->query('update table set sort_order = '.(int)($item_i + 1).' where id = '.(int)$item_id.' limit 1');
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
      'name' => 'Admin Users',
      'icon' => 'icon-user',
      'url'  => 'admin_users.php'
    ),
));
?>
              <div class='row'>
                <div class='col-sm-12'>
                  <div class='box'>
                    <div class='box-content'>
                      <a class="btn btn-success" href="admin_user_edit.php"><i class='icon-plus-sign'> Add new Admin User</i></a>
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
                              <th>Email</th>
                              <th>Status</th>
                              <th></th>
                            </tr>
                          </thead>
                          <tbody>
<?php
foreach ($db->query("select * from admin_users order by name") as $admin) {
?>
                            <tr>
                              <td><?php echo stripslashes($admin['name']); ?></td>
                              <td><?php echo stripslashes($admin['email']); ?></td>
                              <td>
                                <span class="label label-<?php echo ($admin["active"]?"success":"important"); ?>"><?php echo ($admin["active"]?"Active":"Inactive"); ?></span>
                              </td>
                              <td>
                                <input type="hidden" name="item[]" value="<?php echo $admin['id']; ?>" />
                                <div class="text-right">
                                  <a class="btn btn-success btn-xs" href="admin_user_edit.php?id=<?php echo $admin['id']; ?>">
                                    <i class="icon-edit"></i>
                                  </a>
                                  <a class="btn btn-danger btn-xs" href="?delete=<?php echo $admin['id']; ?>" onclick="return confirm('Are you sure you want to delete this admin user?');">
                                    <i class="icon-remove"></i>
                                  </a>
                                </div>
                              </td>
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
