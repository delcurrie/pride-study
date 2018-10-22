<?php
include("includes/application_top.php");

$mode = 'add';
if (!empty($_GET['id'])) {
    $item = $db->query("select * from table_name where id = ".(int)$_GET['id']." limit 1")->fetch(PDO::FETCH_ASSOC);
    if ($item) {
        $mode = 'edit';
    }
}

uploadImage('image', 'DemoModel', array(
    array(
        'width' => 100,
        'height' => 100,
        'crop' => false,
        'folder' => 'image'
    )
));
uploadFile('file', DIR_ROOT . 'files/', URL_BASE . 'files');

// Used for pages with validation

$return_data = array(
  'errors'     => array(),
  'revalidate' => false
);

if (!empty($_POST)) {

    if (empty($return_data['revalidate']) && empty($return_data['errors'])) {

        $data = array(
            'name'     => $_POST['name'],
            'email'    => $_POST['email'],
            'password' => $_POST['password'],
            'image'    => $_POST['image_file'],
            'file'     => $_POST['file_file'],
            'active'   => (int)$_POST['active']
        );
        try {
            if ($mode == 'add') {
                $db->perform("table_name", $data);
            } else {
                $db->perform("table_name", $data, "update", "id = ".(int)$item['id']." limit 1");
            }
        } catch (PDOException $e) {
            echo $e;
            die();
        }

        $return_data['redirect'] = 'elements.php?saved=true';

    }

    echo json_encode($return_data);
    die();

}

addUploadify();
addAutoSize();
addDatePicker();
addTinyMCE();
$required_js[] = 'pages/no_validation.js';

include("includes/header.php");
?>
          <div class="row" id="content-wrapper">
            <div class="col-xs-12">

<?php
drawHeaderRow(array(
    array(
      'name' => 'Link Group',
      'icon' => 'icon-table',
      'url'  => 'admin_users.php'
    ),
    array(
      'name' => 'Elements',
    ),
));
?>

<?php
if ($_GET['saved']) {
?>
              <div class="row">
                <div class="col-sm-12">
                    <div class='alert alert-success alert-dismissable'>
                      <a class="close" data-dismiss="alert" href="#">&times;</a>
                      <h4><i class='icon-ok-sign'></i> Saved!</h4>
                      Content saved successfully
                    </div>
                  </div>
             </div>
<?php
}
?>
              <div class="row">
                <div class="col-sm-12">
                  <div class="box">
                    <div class="box-header dark-grey-background">
                      <div class="title">
                        <div class="icon-edit"></div>
                        Block Header
                      </div>
                    </div>
                    <div class="box-content box-no-padding">
                      <form class="form form-horizontal form-striped" action="#" method="post">
<?php
drawInputBox('text', 'name', 'Name', $admin);

drawInputBox('text', 'email', 'Email', $admin);

drawInputBox('password', 'password', ($mode == 'edit'?'Change ':'') . 'Password', $admin, 'pwstrength');

drawImageUploadField('image', 'Image', $admin, '/assets/img/elements-100x100/', 'Image should be 100x100');

drawFileUploadField('file', 'File', $admin, '/files/', 'File should be PDF, DOC');

drawAutosizeTextArea('auto_size', 'Auto Size', $admin, '', '', '');

drawTinyMCETextArea('tinymce', 'TinyMCE', $item);

drawInputDatepicker('date', 'Date Picker', $item);

drawCheckboxes('checkbox[]', 'Checkbox', array(
  array(
    'value' => 1,
    'label' => 'No',
    'checked' => false,
  ),
  array(
    'value' => 2,
    'label' => 'Yes',
    'checked' => false,
  ),
  array(
    'value' => 3,
    'label' => 'Maybe',
    'checked' => true,
  ),
));

drawSelect('active', array(
    'No', 'Yes'
), 'Active', $admin);
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
