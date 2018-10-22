<?php
include("includes/application_top.php");

if (!empty($_GET['delete'])) {
    $db->query("delete from faqs where id = ".(int)$_GET['delete']." limit 1");
    header("Location: faqs.php");
    exit();
}

if ($_POST['items']) {
  foreach ((array)$_POST['items'] as $item_i => $item_id) {
    $db->query('update faqs set sort_order = '.(int)($item_i + 1).' where id = '.(int)$item_id.' limit 1');
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
      'name' => 'Frequently Asked Questions',
      'icon' => 'icon-question',
      'url'  => 'faqs.php'
    ),
));
?>
              <div class='row'>
                <div class='col-sm-12'>
                  <div class='box'>
                    <div class='box-content'>
                      <a class="btn btn-success" href="faqs_edit.php"><i class='icon-plus-sign'> Add new FAQ</i></a>
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
                            <th>Question</th>
                            <th>Answer</th>
                            <th>Status</th>
                            <th></th>
                          </tr>
                        </thead>
                        <tbody>
<?php
foreach ($db->query("select * from faqs order by sort_order") as $faq) {
?>
                          <tr>
                            <td style="width: 30%;"><?php echo stripslashes($faq['question']); ?></td>
                            <td style="width: 50%;"><?php echo stripslashes($faq['answer']); ?></td>
                            <td>
                              <span class="label label-<?php echo ($faq["active"]?"success":"important"); ?>"><?php echo ($faq["active"]?"Active":"Inactive"); ?></span>
                            </td>
                            <td>
                              <div class="text-right">
                                <input type="hidden" name="items[]" value="<?php echo $faq['id']; ?>" />
                                <a class="btn btn-success btn-xs" href="faqs_edit.php?id=<?php echo $faq['id']; ?>">
                                  <i class="icon-edit"></i>
                                </a>
                                <a class="btn btn-danger btn-xs" href="?delete=<?php echo $faq['id']; ?>" onclick="return confirm('Are you sure you want to delete this faq?');">
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
