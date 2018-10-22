<?php 

/**
 * We need a common interface so we know
 * what to call when listing votes
 * in the users profile activities.
 */
interface VoteInterface
{
	/**
	 * Method to get the text which is
	 * shown when listing this data.
	 * 
	 * @return String
	 */
	public function getVoteText();

	/**
	 * Method to get the formatted date
	 * of the vote which will be displayed
	 * when we're listing it.
	 * 
	 * @return String
	 */
	public function getVoteDate();

	/**
	 * Should return the url to the resource
	 * or it's parent resource, used when listing.
	 * 
	 * @return String
	 */
	public function getVoteUrl();
}