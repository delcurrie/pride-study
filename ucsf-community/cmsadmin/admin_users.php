<?php
include("includes/application_top.php");
$page_title = "Admins";

if (!empty($_GET['id']) && isset($_GET['toggle'])) {
    $db->query("UPDATE admin_users SET active = ".(int)$_GET['toggle']." WHERE id = ".(int)$_GET['id']." limit 1");
    header("Location: admin_users.php");
    exit();
}

include("includes/header.php");
?>
<div class="row" id="content-wrapper">
    <div class="col-xs-12">
        <div class="row">
            <div class="col-sm-12">
                <div class="box">
                    <div class="row box-wrapper">
                        <div class="col-md-4 search-container">
                            <input type="text" placeholder="Search admins" name="search_admins" id="search_admins" class="form-control search typeahead js-search-admins" />
                            <button class="search-button search-button--close js-clear-admin-search"></button>
                        </div>
                        <div class="col-md-4 search-container">
                            <div class="text-right col-xs-9">
                                <a class="btn btn-success" href="admin_user_edit.php"><i class='icon-plus-sign'>Add new admin</i></a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-12">
                <div class="box bordered-box no-bottom-margin">
                    <div class="box-content box-no-padding">
                        <table class="table no-bottom-margin">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Notifications</th>
                                    <th>Status</th>
                                    <th></th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                foreach ($db->query("select * from admin_users order by name") as $admin) {
                                    ?>
                                    <tr class="table_row">
                                        <td class="blue-label"><?php echo stripslashes($admin['name']); ?></td>
                                        <td class="blue-label"><?php echo stripslashes($admin['email']); ?></td>
                                        <td class="standard-label"><?php echo ($admin['receive_notifications'] == 1 ? 'Yes' : 'No'); ?></td>
                                        <td class="standard-label">
                                            <span class=""><?php echo ($admin["active"] ? "Active":"Inactive"); ?></span>
                                        </td>
                                        <td class="green-label">
                                            <div class="text-right">
                                                <a class="" href="admin_user_edit.php?id=<?php echo $admin['id']; ?>">
                                                    Edit
                                                </a>
                                            </div>
                                        </td>
                                        <td class="<?php echo $admin['active'] ? 'red-label': 'green-label'; ?>">
                                            <div class="text-right">
                                                <a href="?toggle=<?php echo $admin['active'] ? 0:1; ?>&id=<?php echo $admin['id']; ?>" onclick="return confirm('Are you sure you want to delete this admin user?');">
                                                    <?php echo $admin['active'] ? 'Deactivate' : 'Activate'; ?>
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
            </div>
        </div>

    </div>
</div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
