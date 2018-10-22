<?php
require '../includes/application_top.php';

if (!empty($_GET['user_id'])) {

    $user_id = (int)$_GET['user_id'];
    $call = $_GET['call'];

    $comment_votes = $db
        ->query("select id, created_at, parent_comment_id, message as title, upvotes, downvotes from comments where user_id = " . $user_id)
        ->fetchAll(PDO::FETCH_ASSOC);

    $topic_votes = $db
        ->query("select id, created_at, title, upvotes, downvotes from topics where user_id = " . $user_id)
        ->fetchAll(PDO::FETCH_ASSOC);

    switch ($call) {

        case 'upvotes':
            ?>
            <table class="table no-bottom-margin">
                <tbody>
                    <?php
                    $upvotes = getVoteDetails($topic_votes, $comment_votes, 'upvotes');

                    foreach ($upvotes as $upvote) {

                        $number_of_comments = 0;
                        $created_at = $upvote['created_at'];

                        if ($upvote['table'] == 'topics') {

                            $number_of_topic_comments = $db
                                ->query("select count(*) from comments where topic_id = " . $upvote['id'])
                                ->fetchColumn();

                            $number_of_comments = $number_of_topic_comments;

                        } elseif ($upvote['table'] == 'comments') {
                            $number_of_comment_comments = $db
                                ->query("select count(*) from comments where parent_comment_id = " . $upvote['id'])
                                ->fetchColumn();

                            $number_of_comments = $number_of_comment_comments;
                        }
                        ?>
                        <tr>
                            <td class="dark-blue-label">
                                <?php
                                echo substr($upvote['title'], 0, 35);
                                echo strlen($upvote['title']) > 35 ? '...': '';
                                ?>
                            </td>
                            <td class="standard-label">
                                <i class="fa fa-clock-o"></i> <?php echo date('m/d/Y g:i a', $created_at); ?>
                            </td>
                            <td class="dark-blue-label"><?php echo $number_of_comments; ?> Comments</td>
                            <td class="dark-blue-label"><?php echo $upvote['upvotes']; ?> Upvotes</td>
                            <td class="dark-blue-label"><?php echo $upvote['downvotes']; ?> Downvotes</td>
                            <td class="green-label">
                                <a href="">View Thread</a>
                            </td>
                        </tr>
                        <?php
                    }
                ?>
                </tbody>
            </table>
            <?php
        break;
    }
}
