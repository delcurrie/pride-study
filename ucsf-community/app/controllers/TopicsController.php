<?php

/**
 * Handles route logic for topics
 *
 * @author Analog Republic
 */
class TopicsController extends BaseController {

	protected $routes = array(
		'/get' 			 => array('action' => 'getTopics'),
		'/create' 	   	 => array(
			'POST' => array('action' => 'doCreateTopic'),
			'GET'  => array('action' => 'showCreateTopic'),
		),

		'/comment/get' 		=> array('GET'  => array('action' => 'getComments')),
		'/comment/flag' 	=> array('POST' => array('action' => 'doCommentFlag')),
		'/comment/unflag' 	=> array('POST' => array('action' => 'doCommentUnFlag')),
		'/comment/upvote' 	=> array('POST' => array('action' => 'doCommentUpvote')),
		'/comment/downvote' => array('POST' => array('action' => 'doCommentDownvote')),
		'/comment' 			=> array('POST' => array('action' => 'doCommentCreate')),

		// '/search' 			=> array('GET'  => array('action' => 'showSearch')),

		'/subscribe' 		=> array('POST' => array('action' => 'doSubscribe')),
		'/upvote' 		    => array('POST' => array('action' => 'doUpvote')),
		'/downvote' 		=> array('POST' => array('action' => 'doDownvote')),
		'/flag' 			=> array('POST' => array('action' => 'doFlag')),
		'/unflag' 			=> array('POST' => array('action' => 'doUnflag')),

		'/:topic/update'    => array('PUT'  => array('action' => 'doUpdateTopic')),
		'/:topic' 			=> array('action' => 'showTopic'),
	);

	public function __construct()
	{
		parent::__construct();
        App::requireAppSession();
	}

	/**
	 * Show a single topic view
	 *
	 * @param  array $params
	 * @return view
	 */
	public function showTopic($params)
	{
		$app = App::getInstance();

		if(!isset($params['topic']) || !is_numeric($params['topic'])) {
			throw new NotFoundException();
		}

		$topic_query = (int)$params['topic'];
		$topic = TopicModel::findById($topic_query);

		if(!$topic) {
			throw new NotFoundException();
		}

		$app->template->addValidation();
		$app->template->setModuleVar('TopicList','topics', array($topic));
		$app->template->setModuleVar('TopicList','single_topic_view', true);
		$app->template->setModuleVar('Navigation', 'show_back', true);
		$app->template->addRequiredJS('pages/topics/comments.js');
		$app->template->addRequiredJS('pages/topics/general.js');
		$app->template->addRequiredJs('pages/topics/show.js');
		$app->template->render('Topics/Show.php',compact('topic'));
	}

	/**
	 * Show a create topic view
	 *
	 * @param  array $params
	 * @return view
	 */
	public function showCreateTopic()
	{
		App::requireLogin();
		$app = App::getInstance();

		$user = App::getLoggedInUser();
		if(!$user->canPostTopics()) throw new NotFoundException;

		$types = TopicCategoryModel::findGroupedByType();

		$app->template->addValidation();
		$app->template->addRequiredJs('pages/topics/create.js');
		$app->template->render('Topics/Create.php', compact('types'));
	}

	/**
	 * (Ajax) Handle retrieval of topics
	 *
	 * @return json
	 */
	public function getTopics()
	{
		$app = App::getInstance();
		$db = Database::getInstance();

		$last_page = false;

    	$offset = 0;
		if(isset($_GET['offset'])) {
			$offset = (int)$_GET['offset'];
		}

		$amount = 5;
		if(isset($_GET['amount'])) {
			$amount = (int)$_GET['amount'];
		}

		if(isset($_GET['term'])) {
        	$total = TopicModel::countByTerm($_GET['term']);
        } else {
			$view_filter = false;
	        if(isset($_GET['view']) && $_GET['view'] != 'false') {
	            $view_filter = $_GET['view'];
	        }

	        $category_filter = false;
	        if(isset($_GET['category']) && $_GET['category'] != 'false') {
	            $category_filter = $_GET['category'];
	        }
			$total = TopicModel::countByfilter($view_filter, $category_filter);
        }

        if(isset($_GET['term'])) {
        	$topics = TopicModel::findByTerm($_GET['term'], $amount, $offset);
        } else {
			$view_filter = false;
	        if(isset($_GET['view']) && $_GET['view'] != 'false') {
	            $view_filter = $_GET['view'];
	        }

	        $category_filter = false;
	        if(isset($_GET['category']) && $_GET['category'] != 'false') {
	            $category_filter = $_GET['category'];
	        }
			$topics = TopicModel::filter($view_filter, $category_filter, $amount, $offset);
        }

		$app->template->setModuleVar('TopicList', 'topics', $topics);
		$count = count($topics);

		if ($count + $offset >= $total) {
			$last_page = true;
		}

		ob_start();
		$app->template->render('Ajax/Topics.php');
		$html = ob_get_clean();

		die(json_encode(array(
			'html' => $html,
			'count' => $count,
			'last_page' => $last_page
		)));
	}

	/**
	 * Get comments
	 *
	 * @return json
	 */
	public function getComments()
	{
		$app = App::getInstance();
		$db = Database::getInstance();

		$last_page = false;

		$offset = 0;
		if(isset($_GET['offset'])) {
			$offset = (int)$_GET['offset'];
		}

		$amount = 5;
		if(isset($_GET['amount'])) {
			$amount = (int)$_GET['amount'];
		}

		if(!isset($_GET['topic_id'])) {
			throw new NotFoundException();
		}

		$topic_id = (int)$_GET['topic_id'];

		$total = CommentModel::countByTopic($topic_id, true);
		$comments = CommentModel::findByTopic($topic_id, true, $offset, $amount);
		$app->template->set('comments', $comments);

		$count = count($comments);

		if ($count + $offset >= $total) {
			$last_page = true;
		}

		ob_start();
		$app->template->render('Ajax/Comments.php');
		$html = ob_get_clean();

		die(json_encode(array(
			'html' => $html,
			'count' => $count,
			'last_page' => $last_page
		)));
	}

	/**
	 * (Ajax) Handle POST request to create a topic
	 *
	 * @return json
	 */
	public function doCreateTopic()
	{
		$response = array(
			'revalidate' => false,
			'errors' => array(),
			'redirect' => false
		);

		if(!App::loggedIn() || !App::getLoggedInUser()->canPostTopics()) {
			$response['redirect'] = URL_BASE.'community';
			die(json_encode($response));
		}

		$db = Database::getInstance();
		$app = App::getInstance();


		// Validate
		$validator = Validator::make($_POST, array(
			'title' 	  => 'required',
			'description' => 'required'
		))->process();

		// Check if failed
		if($validator->failed()) {
			$response['errors'] = $validator->getErrors();
			$response['revalidate'] = true;
			die(json_encode($response));
		}

		// Extract data
		$title = $_POST['title'];
		$description = $_POST['description'];
		$categories = array();
		if(isset($_POST['topic_categories'])) {
			$categories = $_POST['topic_categories'];
		}

		// Handle existing topics
		$exists = TopicModel::find(array('title = :title'), array(':title' => $title), 'limit 1');
		if(isset($exists[0])) {
			$response['errors'] = array('title' => 'Topic with this title already exists.');
			$response['revalidate'] = true;
			die(json_encode($response));
		}

		// Create the topic
		$topic = TopicModel::create(array(
			'title' => $title,
			'description' => $description,
			'user_id' => App::getLoggedInUser()->getId(),
			'created_at' => time(),
			'active' => 1
		));

		// If we couldn't create it for some reason, tell the users
		if(!$topic) {
			$response['errors'] = array('title' => 'Unable to create topic.');
			$response['revalidate'] = true;
			die(json_encode($response));
		}

		foreach($categories as $category) {
			$db->perform('topics_to_topic_categories', array(
				'topic_category_id' => (int)$category,
				'topic_id' => $topic->getId(),
			));
		}

		// Fire an event to say the topic
		// has been posted.
		TopicEventHandler::fire('topic.post', $topic);

		$response['redirect'] = URL_BASE.'community/topics/' . $topic->getId();
		die(json_encode($response));
	}

	/**
	 * (Ajax) Handle PUT update of topic
	 *
	 * @param  array $params
	 * @return json
	 */
	public function doUpdateTopic($params)
	{
		if(!App::loggedIn()) throw new NotFoundException();

	}

	/**
	 * (Ajax) Handle comment creation
	 *
	 * @return json
	 */
	public function doCommentCreate()
	{
		if(!App::loggedIn() || !App::getLoggedInUser()->canPostComments()) {
			$response['redirect'] = URL_BASE.'community';
			die(json_encode($response));
		}

		$app = App::getInstance();
		$db = Database::getInstance();

		$response = array(
			'revalidate' => true,
			'errors' => array()
		);

		$validator = Validator::make($_POST, array(
			'topic_id' => 'required',
			'message'  => 'required',
		))->process();

		if($validator->failed()) {
			$response['errors'] = $validator->getErrors();
			$response['revalidate'] = true;
			die(json_encode($response));
		}

		$id = (int)$_POST['topic_id'];

		$user = App::getLoggedInUser();
		$topic = TopicModel::findById($id);


		if(!$topic) {
			throw new NotFoundException();
		}

		$parent_comment = null;
		if(isset($_POST['parent_comment_id'])) {
			$parent_comment = (int)$_POST['parent_comment_id'];
		}

		$comment_data = array(
			'user_id' => $user->getId(),
			'topic_id' => $topic->getId(),
			'parent_comment_id' => $parent_comment,
			'message' => $_POST['message'],
			'created_at' => time()
		);

		$comment = CommentModel::create($comment_data);
		if(!$comment) {
			$response['errors']['message'] = 'Unable to add comment';
			$response['revalidate'] = true;
			die(json_encode($response));
		}

		TopicEventHandler::fire('topic.update', $topic);
		TopicEventHandler::fire('topic.reply', $topic, $comment);

		if($parent_comment != null) {
			$parent = CommentModel::findById($parent_comment);
			CommentEventHandler::fire('comment.reply', $topic, $parent, $comment);
		}

		die(json_encode(array(
			'added' => 'true'
		)));
	}

	/**
	 * Handle subscribing/unsubscribing to a topic
	 *
	 * @return json
	 */
	public function doSubscribe()
	{
		if(!App::loggedIn()) throw new NotFoundException();

		$app = App::getInstance();

		$response = array(
			'revalidate' => true,
			'errors' => array()
		);

		if(isset($_POST['topic_id']) && is_numeric($_POST['topic_id'])) {
			$topic = $_POST['topic_id'];
			$user = App::getLoggedInUser();
			$subscribed = (bool)$user->toggleSubscribe($topic);
		}

		$topic = TopicModel::findById($topic);
		TopicEventHandler::fire('topic.update', $topic);

		die(json_encode(array(
			'subscribed' => $subscribed,
			'topic_id'  => $topic
		)));
	}

	/**
	 * Handle the request to upvote a given
	 * topic.
	 *
	 * @return json
	 */
	public function doUpvote()
	{
		if(!App::loggedIn()) throw new NotFoundException();

		if(isset($_POST['topic_id']) && is_numeric($_POST['topic_id'])) {
			$app = App::getInstance();
			$topic = TopicModel::findById($_POST['topic_id']);
			$user = App::getLoggedInUser();

			if ($user->canVote($topic)) {
				$upvoted = (bool)$user->toggleUpvote($topic);

				TopicEventHandler::fire('topic.update', $topic);

				die(json_encode(array(
					'upvoted' => $upvoted,
					'topic_id'  => $topic->getId(),
					'upvoteCount' => $topic->getUpvotes(),
					'downvoteCount' => $topic->getDownvotes(),
				)));
			} else {
				$response['redirect'] = URL_BASE.'community';
				die(json_encode($response));
			}
		}
	}

	/**
	 * Handle the request to downvote a given topic
	 *
	 * @return json
	 */
	public function doDownvote()
	{
		if(!App::loggedIn()) throw new NotFoundException();

		if(isset($_POST['topic_id']) && is_numeric($_POST['topic_id'])) {
			$app = App::getInstance();
			$topic = TopicModel::findById($_POST['topic_id']);
			$user = App::getLoggedInUser();

			if ($user->canVote($topic)) {
				$downvoted = (bool)$user->toggleDownvote($topic);

				TopicEventHandler::fire('topic.update', $topic);

				die(json_encode(array(
						'downvoted' => $downvoted,
						'topic_id'  => $topic->getId(),
						'upvoteCount' => $topic->getUpvotes(),
						'downvoteCount' => $topic->getDownvotes(),
				)));
			} else {
				$response['redirect'] = URL_BASE.'community';
				die(json_encode($response));
			}
		}
	}

	/**
	 * Handle flagging a topic
	 *
	 * @return json
	 */
	public function doFlag()
	{
		if(!App::loggedIn()) throw new NotFoundException();

		$app = App::getInstance();

		$flagged = false;
		if(isset($_POST['topic_id']) && is_numeric($_POST['topic_id'])) {
			$topic = TopicModel::findById($_POST['topic_id']);
			$user = App::getLoggedInUser();
			$flagged = $user->flagTopic($topic);
			if($flagged) {
				TopicEventHandler::fire('topic.flag', $topic);
			}
		}

		TopicEventHandler::fire('topic.update', $topic);

		die(json_encode(array(
			'flagged' => $flagged,
			'topic_id'  => $topic->getId(),
		)));
	}

	/**
	 * Handle un-flagging a topic
	 *
	 * @return json
	 */
	public function doUnflag()
	{
		if(!App::loggedIn()) throw new NotFoundException();

		$app = App::getInstance();

		$unflagged = false;
		if(isset($_POST['topic_id']) && is_numeric($_POST['topic_id'])) {
			$topic = TopicModel::findById($_POST['topic_id']);
			$user = App::getLoggedInUser();
			$unflagged = $user->unflagTopic($topic);
		}

		TopicEventHandler::fire('topic.update', $topic);

		die(json_encode(array(
			'unflagged' => $unflagged,
			'topic_id'  => $topic->getId(),
		)));
	}

	/**
	 * Handle upvoting a comment
	 *
	 * @return json
	 */
	public function doCommentUpvote()
	{
		if(!App::loggedIn() || !App::getLoggedInUser()->canVote()) {
			$response['redirect'] = URL_BASE.'community';
			die(json_encode($response));
		}

		$app = App::getInstance();

		$downvoted = false;
		if(isset($_POST['comment_id']) && is_numeric($_POST['comment_id'])) {
			$comment = CommentModel::findById($_POST['comment_id']);
			$user = App::getLoggedInUser();
			$downvoted = (bool)$user->toggleUpvoteComment($comment);
		}

		die(json_encode(array(
			'upvoted' => $downvoted,
			'comment_id'  => $comment->getId(),
			'upvoteCount' => $comment->getUpvotes(),
			'downvoteCount' => $comment->getDownvotes(),
		)));
	}

	/**
	 * Handle downvoting a comment
	 *
	 * @return json
	 */
	public function doCommentDownvote()
	{
		if(!App::loggedIn() || !App::getLoggedInUser()->canVote()) {
			$response['redirect'] = URL_BASE.'community';
			die(json_encode($response));
		}

		$app = App::getInstance();

		$downvoted = false;
		if(isset($_POST['comment_id']) && is_numeric($_POST['comment_id'])) {
			$comment = CommentModel::findById($_POST['comment_id']);
			$user = App::getLoggedInUser();
			$downvoted = (bool)$user->toggleDownvoteComment($comment);
		}

		die(json_encode(array(
			'downvoted' => $downvoted,
			'comment_id'  => $comment->getId(),
			'upvoteCount' => $comment->getUpvotes(),
			'downvoteCount' => $comment->getDownvotes(),
		)));
	}

	/**
	 * Handle unflagging a comment
	 * 
	 * @return json
	 */
	public function doCommentUnFlag()
	{
		if(!App::loggedIn()) throw new NotFoundException();

		$app = App::getInstance();

		$unflagged = false;
		if(isset($_POST['comment_id']) && is_numeric($_POST['comment_id'])) {
			$comment = CommentModel::findById($_POST['comment_id']);
			$user = App::getLoggedInUser();
			$unflagged = (bool)$user->unflagComment($comment);
		}

		die(json_encode(array(
			'unflagged' => $unflagged,
			'comment_id'  => $comment->getId(),
		)));
	}

	/**
	 * Handle the flagging of a comment
	 *
	 * @return json
	 */
	public function doCommentFlag()
	{
		if(!App::loggedIn()) throw new NotFoundException();

		$app = App::getInstance();

		$flagged = false;
		if(isset($_POST['comment_id']) && is_numeric($_POST['comment_id'])) {
			$comment = CommentModel::findById($_POST['comment_id']);
			$user = App::getLoggedInUser();
			$flagged = (bool)$user->flagComment($comment);
			if($flagged) {
				CommentEventHandler::fire('comment.flag', $comment);
			}
		}

		die(json_encode(array(
			'flagged' => $flagged,
			'comment_id'  => $comment->getId(),
		)));
	}

}