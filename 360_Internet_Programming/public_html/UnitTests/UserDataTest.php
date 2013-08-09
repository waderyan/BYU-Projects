<?php
include_once 'ITest.php';
include_once '../Model/UserData.php';

class UserDataTest implements ITest
{

    private function testConstructor(){
       $password = "validPswd";
       $username = "validUsername";

       $emptyPassword = "";
       $emptyUsername = "";

       try{
          $user = new UserData($password,$username);
       } catch(Exception $ex){
        //MyAssertFail("should not throw exception valid username and password");
       }

        try{
          $user = new UserData($emptyPassword,$emptyUsername);
          //MyAssertFail("should thrown an exception because of emtpy username and password");
       } catch(Exception $ex){

       }


       
    }

    public function Run(){
        echo "....... Testing UserDataTest...........\n";
        $this->testConstructor();
    }
}

?>