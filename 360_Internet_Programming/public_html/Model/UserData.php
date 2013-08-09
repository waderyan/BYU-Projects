<?php
include_once 'BaseData.php';
include_once '../Utilities.php';

/**
*  UserData stores data for a user
*/
class UserData extends BaseData{

	//Properties

	public $_password;
	public $_username;

	//Constructor

	/**
	* Constructor takes a password and a username
	* password != null or empty
	* username != null or empty
	*/
	public function __construct($password, $username){

		if(IsNullOrEmptyString($password) 
			|| IsNullOrEmptyString($username))
			throw new Exception('null or empty password/username is not allowed');

		$this->_password = $password;
		$this->_username = $username;
	}

	/**
	*  Returns true if the users are the same
	*  false otherwise
	*/
	public function Equals($usr2){
		return (strcmp($this>_password,$usr2->_password) == 0)
				&& (strcmp($this->_username,$usr1->_username) == 0);
	}

}

?>