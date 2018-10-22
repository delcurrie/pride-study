<?php
require 'includes/application_top.php';

$page_title = 'Participants';

if (!empty($_GET['id'])) {

    $user_id = (int)$_GET['id'];

    $user = $db->query(
        "select * from users u
        join users_details ud on ud.user_id = u.id
        where u.id = " . $user_id . " limit 1")->fetch(PDO::FETCH_ASSOC);

    $flagged = $db->query(
        "select * from topic_flags
        where user_id = " . $user_id)->fetch(PDO::FETCH_ASSOC);

    $number_of_topics = $db
        ->query("select count(*) from topics where user_id = " . $user_id)
        ->fetchColumn();

    $number_of_comments = $db
        ->query("select count(*) from comments where user_id = " . $user_id)
        ->fetchColumn();

    $comment_votes = $db
        ->query("select id, created_at, parent_comment_id, message as title, upvotes, downvotes from comments where user_id = " . $user_id)
        ->fetchAll(PDO::FETCH_ASSOC);

    $topic_votes = $db
        ->query("select id, created_at, title, upvotes, downvotes from topics where user_id = " . $user_id)
        ->fetchAll(PDO::FETCH_ASSOC);


    $number_of_votes = calculateNumberOfVotes($topic_votes, $comment_votes);
    $number_of_upvotes = $number_of_votes['number_of_upvotes'];
    $number_of_downvotes = $number_of_votes['number_of_downvotes'];


    $upvotes = getVoteDetails($topic_votes, $comment_votes, 'upvotes');
    $downvotes = getVoteDetails($topic_votes, $comment_votes, 'downvotes');


    echo '<pre>';
    foreach ($upvotes as $upvote) {
        print_r($upvote);
    }

    foreach ($downvotes as $downvote) {
        print_r($downvote);
    }
    echo '</pre>';

}

include 'includes/header.php';
?>
<div class="row" id="content-wrapper">
    <div class="col-xs-6">
        <h1 class="no-transform">
            <?php
            if (strlen($user['screen_name']) > 0) {
                echo $user['screen_name'] . "'s profile";
            } else {
                echo 'Profile';
            }
            ?>
        </h1>
    </div>
    <div class="col-xs-6 profile-actions">
        <button class="btn btn-light">Login</button>
        <button class="btn btn-light">Reset pw</button>
        <button class="btn btn-light">Privileges</button>
        <button class="btn btn-success">Export User</button>
    </div>
</div>

<?php
if (!empty($flagged)) {
    ?>
    <div class="row flagged">
        <span class="flagged-label">User has a flagged post</span>
        <span class="view-btn-wrapper">
            <button class="btn ">View</button>
        </span>
    </div>
    <?php
}
?>

<div class="box-wrapper">
    <div class="box bordered-box profile-stats">
        <div class="box-content">
            <a href="javascript:;" class="toggle-profile-section" id="toggle-profile-topics">
                <div class="col-md-3 text-center">
                    <h2><?php echo $number_of_topics; ?></h2>
                    <h5>Topics</h5>
                </div>
            </a>
            <a href="javascript:;" class="toggle-profile-section" id="toggle-profile-comments">
                <div class="col-md-3 text-center">
                    <h2><?php echo $number_of_comments; ?></h2>
                    <h5>Comments</h5>
                </div>
            </a>
            <a href="javascript:;" class="toggle-profile-section" id="toggle-profile-upvotes">
                <div class="col-md-3 text-center">
                    <h2><?php echo $number_of_upvotes; ?></h2>
                    <h5>Upvotes</h5>
                </div>
            </a>
            <a href="javascript:;" class="toggle-profile-section" id="toggle-profile-downvotes">
                <div class="col-md-3 text-center">
                    <h2><?php echo $number_of_downvotes; ?></h2>
                    <h5>Downvotes</h5>
                </div>
            </a>
        </div>
    </div>
</div>

<div id="profile-content">
    <div class="box bordered-box profile-table" id="profile-activity-table">
        <div class="box-content">
            <div class="row">
                <div class="col-sm-12">
                    <h5>Activity</h5>
                </div>
            </div>
            <table class="table no-bottom-margin">
                <tbody>
                    <tr>
                        <td>foo</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div class="box bordered-box profile-table" id="profile-topics-table">
        <div class="box-content">
            <div class="row">
                <div class="col-sm-12">
                    <h5>Topics</h5>
                </div>
            </div>
            <table class="table no-bottom-margin">
                <tbody>
                    <tr>
                        <td>foo</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div class="box bordered-box profile-table" id="profile-comments-table">
        <div class="box-content">
            <div class="row">
                <div class="col-sm-12">
                    <h5>Comments</h5>
                </div>
            </div>
            <table class="table no-bottom-margin">
                <tbody>
                    <tr>
                        <td>foo</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div class="box bordered-box profile-table" id="profile-upvotes-table">
        <div class="box-content">
            <div class="row">
                <div class="col-sm-12">
                    <h5>Upvotes</h5>
                </div>
            </div>
        </div>
    </div>

    <div class="box bordered-box profile-table" id="profile-downvotes-table">
        <div class="box-content">
            <div class="row">
                <div class="col-sm-12">
                    <h5>Downvotes</h5>
                </div>
            </div>
            <table class="table no-bottom-margin">
                <tbody>
                    <tr>
                        <td>foo</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
<input type="hidden" name="user_id" id="user_id" value="<?php echo $user_id; ?>" />

<?php
include "includes/footer.php";
include "includes/application_bottom.php";
