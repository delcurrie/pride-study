<?php
include("includes/application_top.php");

$mode = 'add';
if (!empty($_GET['id'])) {
    $category = $db->query("select * from topic_categories where id = ".(int)$_GET['id']." limit 1")->fetch(PDO::FETCH_ASSOC);
    if ($category) {
        $mode = 'edit';
    }
}

$return_data = array(
  'errors'     => array(),
  'revalidate' => false
);

if (!empty($_POST)) {

    if (empty($return_data['revalidate']) && empty($return_data['errors'])) {

        $data = array(
          'name' => $_POST['name'],
          'slug' => clean_url($_POST['name']),
          'type' => $_POST['type'],
          'active' => (int)$_POST['active'],
        );

        if ($mode == 'add') {
            $db->perform("topic_categories", $data);
        } else {
            $db->perform("topic_categories", $data, "update", "id = ".(int)$category['id']." limit 1");
        }

        $return_data['redirect'] = 'topic_categories.php';

    }

    echo json_encode($return_data);
    die();

}

addValidation();
$required_js[] = 'pages/topic_categories_edit.js';

include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">
            <?php
            drawHeaderRow(array(
                array(
                  'name' => 'Topic Category',
                  'icon' => 'icon-comment',
                  'url'  => 'topic_categories.php'
                ),
                array(
                  'name' => ucfirst($mode) . ' Topic Category',
                  'icon' => 'icon-edit',
                ),
            ));
            ?>

              <div class="row">
                <div class="col-sm-12">
                  <div class="box">
                    <div class="box-header dark-grey-background">
                      <div class="title">
                        <div class="icon-edit"></div>
                        <?php echo ucfirst($mode); ?> Topic Category
                      </div>
                    </div>
                    <div class="box-content box-no-padding">
                      <form class="form form-horizontal form-striped" action="#" method="get">
                        <?php
                          drawInputBox('text', 'name', 'Name', $category);
                          drawSelect('type', array(
                              array('value' => 'age', 'label' => 'Age'),
                              array('value' => 'health', 'label' => 'Health'),
                              array('value' => 'identity', 'label' => 'Identity'),
                          ), 'Type', $category);
                          drawSelect('active', array(
                              'No', 'Yes'
                          ), 'Active', $category);
                        ?>
                        <div class="form-actions" style="margin-bottom: 0;">
                          <div class="row">
                            <div class="col-md-9 col-md-offset-3">
                              <button class="btn btn-primary btn-lg" type="submit">
                                <i class="icon-save"></i>
                                Save
                              </button>
                            </div>
                          </div>
                        </div>
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
