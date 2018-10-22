<?php
include("includes/application_top.php");

if (!empty($_GET['delete'])) {
    $db->query("delete from table where id = ".(int)$_GET['delete']." limit 1");
    header("Location: pagination_list.php");
    exit();
}

include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">

<?php
drawHeaderRow(array(
    array(
      'name' => 'Pagination List',
    ),
));
?>

              <div class="row">
                <div class="col-sm-12">
                  <div class="box bordered-box purple-border no-bottom-margin">
                    <div class="box-content box-no-padding">
                      <table class="table table-striped no-bottom-margin">
                        <thead>
                          <tr>
                            <th>Name</th>
                            <th>Status</th>
                            <th></th>
                          </tr>
                        </thead>
                        <tbody>
<?php
$per_page = 50;
$page = (int)$_GET['page'];
if (empty($page))
    $page = 1;
$start = (($per_page * $page) - $per_page);

$items = $db->query("select * from table order by sort_order limit ".$start.', '.$per_page);
$total_items = $db->query('select count(id) from table')->fetchColumn();
$total_pages = ceil($total_items / $per_page);

foreach ($items as $item) {
?>
                          <tr>
                            <td><?php echo stripslashes($item['name']); ?></td>
                            <td>
                              <input type="hidden" name="item[]" value="<?php echo $item['id']; ?>" />
                              <div class="text-right">
                                <a class="btn btn-success btn-xs" href="admin_user_edit.php?id=<?php echo $item['id']; ?>">
                                  <i class="icon-edit"></i>
                                </a>
                                <a class="btn btn-danger btn-xs" href="?delete=<?php echo $item['id']; ?>" onclick="return confirm('Are you sure you want to delete this admin user?');">
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
                    </div>
                  </div>
                  <ul class='pagination pagination-sm'>
<?php
$url = 'pagination_list.php?page=';

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
