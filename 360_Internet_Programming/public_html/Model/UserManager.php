<?php
include_once 'IUserManager.php';
include_once 'DAO.php';

/**
* User Manager manages all users
*/
class UserManager implements IUserManager{

	// Constructor

	private static $instance;

	public static function GetInstance(){
		if($instance == null)
			$instance = new UserManager();

		return $instance;
	}

	private function __construct(){	
		
	}

	/**
	* Loads all users from database
	*/
	private function LoadUsers(){
		try{
			$dao = new DAO();
			$users = $dao->GetUsers();
		} catch(Exception $ex){
			echo "ERROR getting images from database! " . $ex->getMessage();
		}

		return $users;
	}

	//IUserManager Operations

	//Override
	public function Add($user){
		if(!$this->CanAdd($user))
			throw new Exception("cannot add user because canAdd() is false");

		$dao = new DAO();
		try{
			$dao->InsertUser($user);
		} catch(Exception $ex){
			echo "ERROR inserting user to database!";
		}	
	}

	//Override
	public function CanAdd($user){
		if($user == null)
			return false;

		return true;
	}

	//Override
	public function Validate($user){
		$users = $this->LoadUsers();

		foreach($users as $usr){
			if($usr->Equals($user))
				return true;
		}

		return false;
	}

}

?>