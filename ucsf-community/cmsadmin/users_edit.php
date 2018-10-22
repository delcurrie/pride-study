<?php
include("includes/application_top.php");
$page_title = "Participants";

if (!empty($_GET['id'])) {
    $user = $db->query(
        "select *, u.id as id from users u
        join users_details ud on ud.user_id = u.id
        where u.id = ".(int)$_GET['id']." limit 1")->fetch(PDO::FETCH_ASSOC);
}

$return_data = array(
    'errors'     => array(),
    'revalidate' => false
);

$restrictions = array(
    'commenting' => 1,
    'posting'    => 2,
    'voting'     => 3
);

/*
 * NOTE! This logic has flipped as of 6/6/16.  What was previously "Disallow" is now "Allow".
 */
if (!empty($_POST['posted'])) {

    if (empty($return_data['revalidate']) && empty($return_data['errors'])) {

        $db->query('delete from users_restrictions where user_id = ' . $user['id']);

        foreach(array_values($restrictions) as $restriction) {
            if (!in_array($restriction, $_POST['restrictions'])) {
                $db->perform('users_restrictions', array(
                    'user_id' => $user['id'],
                    'type_id' => $restriction
                ));
            }
        }

        $return_data['redirect'] = 'users_edit.php?id=' . $user['id'];

    }

    echo json_encode($return_data);
    die();

}

addValidation();
$required_js[] = 'pages/no_validation.js';
$required_js[] = 'pages/participants_privileges.js';


$restrictions = array();
$restriction_types = array(
    array('value' => UserModel::DISALLOW_COMMENTS, 'label' => 'Allow commenting'),
    array('value' => UserModel::DISALLOW_TOPICS, 'label' => 'Allow posting topics'),
    array('value' => UserModel::DISALLOW_VOTING, 'label' => 'Allow voting'),
);
foreach($restriction_types as $restriction) {
    $checked = $db
        ->query('select * from users_restrictions where user_id = ' . (int)$_GET['id'] . ' and type_id = ' . $restriction['value'])
        ->fetch(PDO::FETCH_ASSOC);

    $restrictions[] = array(
        'value'   => $restriction['value'],
        'label'   => $restriction['label'],
        'checked' => !(bool)$checked,
        'id'      => 'restriction-' . $restriction['value']
    );
}

include("includes/header.php");
?>
<div class="row" id="content-wrapper">
    <div class="col-xs-12">
        <h1 class="no-transform">
            <?php
            if (strlen($user['screen_name']) > 0) {
                echo $user['screen_name'] . "'s privileges";
            } else {
                echo 'Privileges';
            }
            ?>
        </h1>
        <div class="row form-controls">
            <div class="box">
                <form class="form form-horizontal" action="#" method="get">
                    <div class="privileges">
                        <?php
                        drawCheckboxes('restrictions[]', '', $restrictions);
                        ?>
                        <div class="form-actions" style="margin-bottom: 0;">
                            <input type="hidden" name="posted" value="true">
                            <div class="row save-btn-wrapper">
                                <button class="btn btn-success" type="submit">
                                    Save
                                </button>
                            </div>
                        </div>
                        <?php if ($user['banned']) { ?>
                            <div class="privileges__blocker"></div>
                        <?php }; ?>
                    </div>

                    <div class="row ban-btn-wrapper">

                        <?php if ($user['banned']) { ?>
                            <div class="btn-action">
                                <a class="btn btn-ban-user btn-ban-user--confirm" href="users.php?ban=<?php echo $user['id']; ?>">
                                    Unban User
                                </a>
                            </div>
                        <?php } else { ?>

                            <div class="btn-action">
                                <a class="btn btn-ban-user btn-ban-user--trigger" href="users.php?ban=<?php echo $user['id']; ?>">
                                    Ban User
                                </a>
                            </div>
                            <div class="btn-confirm">
                                <p>Are you sure you want to ban <?php echo $user['screen_name']; ?>?</p>
                                <a class="btn btn-ban-user btn-ban-user--confirm" href="users.php?ban=<?php echo $user['id']; ?>">Yes</a>
                                <a class="btn btn-ban-user btn-ban-user--cancel" href="#">Cancel</a>
                            </div>

                        <?php }; ?>
                    </div>

                </form>


            </div>
        </div>
    </div>
</div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
