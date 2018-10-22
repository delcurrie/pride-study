<?php 

/**
 * Represent something that is flaggable
 */
interface FlaggableModel {

	public function isArchived();
	public function getUserId();
	
}