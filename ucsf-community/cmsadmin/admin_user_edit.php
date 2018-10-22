<?php
include("includes/application_top.php");
$page_title = "Admins";

$mode = 'add';
if (!empty($_GET['id'])) {
    $admin = $db->query("select * from admin_users where id = ".(int)$_GET['id']." limit 1")->fetch(PDO::FETCH_ASSOC);
    if ($admin) {
        $mode = 'edit';
    }
}

$return_data = array(
    'errors'     => array(),
    'revalidate' => false
);

if (!empty($_POST)) {

    if (empty($_POST['name'])) {
        $return_data['revalidate'] = true;
    }
    if (empty($_POST['email'])) {
        $return_data['revalidate'] = true;
    } elseif (!filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
        $return_data['revalidate'] = true;
    } else {
        $check_email = ($db->query("select count(*) from admin_users where email like ".$db->quote($_POST['email'])." and id != ".(int)$admin['id'])->fetchColumn() > 0);
        if ($check_email) {
            $return_data['errors']['email'] = 'Email address already associated with an Admin.';
        }
    }
    if ($mode == 'add') {
        if (empty($_POST['password'])) {
            $return_data['revalidate'] = true;
        }
    }

    if (empty($return_data['revalidate']) && empty($return_data['errors'])) {

        $data = array(
            'name' => $_POST['name'],
            'email' => $_POST['email'],
            'receive_notifications' => (int)$_POST['receive_notifications'],
            'active' => (int)$_POST['active'],
        );
        if ($mode == 'add' || ($mode == 'edit' && !empty($_POST['password']))) {
            $data['password'] = md5($_POST['password']);
        }
        if ($mode == 'add') {
            $db->perform("admin_users", $data);
        } else {
            $db->perform("admin_users", $data, "update", "id = ".(int)$admin['id']." limit 1");
        }

        $return_data['redirect'] = 'admin_users.php';

    }

    echo json_encode($return_data);
    die();

}

addValidation();
addPWStrength();
$required_js[] = 'pages/admin_user_edit.js';

include("includes/header.php");
?>
<div class="row" id="content-wrapper">
    <div class="">
        <div class="row">
            <div class="">
                <div class="box">
                    <div class="box-no-padding full-width-cap">
                        <form class="form form-horizontal" action="#" method="get" autocomplete="off">
                            <?php
                            if ($mode == 'add') {
                                $admin['receive_notifications'] = 1;
                                $admin['active'] = 1;
                            }
                            drawInputBox('text', 'name', 'Name', $admin);
                            drawInputBox('text', 'email', 'Email', ($mode == 'add' ? array('email' => ' '):$admin));
                            drawInputBox('password', 'password', ($mode == 'edit' ? 'Change ':'') . 'Password', $admin, 'pwstrength' . ($mode == 'edit'?' optional':''));
                            drawSelect('receive_notifications', array(
                                'Off', 'On'
                            ), 'Notifications', $admin);
                            drawSelect('active', array(
                                'Inactive', 'Active'
                            ), 'Status', $admin);
                            ?>
                            <div class="form-actions">
                                <div class="row">
                                    <div class="btn-wrapper">
                                        <button class="btn btn-success" type="submit">
                                            Save
                                        </button>
                                        <button class="btn btn-default cancel" type="button">
                                            Cancel
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
