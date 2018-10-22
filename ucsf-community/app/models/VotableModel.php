<?php 

/**
 * Represent something that is votable
 */
interface VotableModel {

	public function isArchived();
	public function getUserId();
	
}