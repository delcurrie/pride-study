<?php 

/**
 * In this file we register all of the events
 * to the handler methods.
 */

// Topic update
TopicEventHandler::register('topic.update', 'updated');

// Topic post
TopicEventHandler::register('topic.post', 'posted');

// Topic reply
TopicEventHandler::register('topic.reply', 'replied');

// Topic comment
TopicEventHandler::register('topic.comment', 'update');

// Topic flagged
TopicEventHandler::register('topic.flag', 'flagged');

// Comment reply
CommentEventHandler::register('comment.reply', 'replied');

// Comment Flagged
CommentEventHandler::register('comment.flag', 'flagged');