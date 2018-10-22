<?php 

/**
 * Represent something that is subscribable
 */
interface SubscribableModel {

	public function isArchived();
	public function getUserId();

}