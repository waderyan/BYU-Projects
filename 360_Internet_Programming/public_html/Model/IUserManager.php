<?php

/**
* Interface for Admin Manager operations
*/
interface IUserManager{

	/**
	* Insert User
	* Equivalent to:
	* Add user to list of users
	* Inserts user into database
	*/
	public function Add($user);

	/**
	* Checks to see if a user can be added
	* Returns true if user can be added, false otherwise
	*/
	public function CanAdd($user);


	/** 
	* Authenticate user takes user info and 
	* verifies if they exisit in the database
	* Equivalent to:
	* Tries to get user from database
	* if user does exist returns true
	* if user doesn't exist database returns null
	* and function returns false
	*/
	public function Validate($user);

}

?>