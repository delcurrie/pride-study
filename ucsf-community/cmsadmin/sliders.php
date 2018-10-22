<?php
include("includes/application_top.php");

if (!empty($_GET['delete'])) {
    $db->query("delete from slides where id = ".(int)$_GET['delete']." limit 1");
    header("Location: sliders.php");
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
      'name' => 'Welcome Sliders',
      'icon' => 'icon-picture',
      'url'  => 'sliders.php'
    ),
));
?>
              <div class='row'>
                <div class='col-sm-12'>
                  <div class='box'>
                    <div class='box-content'>
                      <a class="btn btn-success" href="sliders_edit.php"><i class='icon-plus-sign'> Add new Slider</i></a>
                    </div>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-sm-12">
                  <div class="box bordered-box purple-border no-bottom-margin">
                  <form>
                    <div class="box-content box-no-padding">
                      <table class="table table-striped no-bottom-margin sortable-table">
                        <thead>
                          <tr>
                            <th>Number</th>
                            <th>Image</th>
                            <th>Text</th>
                            <th></th>
                          </tr>
                        </thead>
                        <tbody>
<?php
foreach ($db->query("select * from slides order by sort_order") as $slide) {
?>
                          <tr>
                            <td><?php echo $slide['sort_order']; ?></td>
                            <td><img width="200" src="<?php echo SlideModel::getImageFolder('slides') . $slide['image']; ?>"/></td>
                            <td><?php echo $slide['text']; ?></td>
                            <td>
                              <span class="label label-<?php echo ($slide["active"]?"success":"important"); ?>"><?php echo ($slide["active"]?"Active":"Inactive"); ?></span>
                            </td>
                            <td>
                              <div class="text-right">
                                <input type="hidden" name="items[]" value="<?php echo $slide['id']; ?>" />
                                <a class="btn btn-success btn-xs" href="sliders_edit.php?id=<?php echo $slide['id']; ?>">
                                  <i class="icon-edit"></i>
                                </a>
                                <a class="btn btn-danger btn-xs" href="?delete=<?php echo $slide['id']; ?>" onclick="return confirm('Are you sure you want to delete this slide?');">
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
                    </form>
                  </div>
                </div>
              </div>

            </div>
          </div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
