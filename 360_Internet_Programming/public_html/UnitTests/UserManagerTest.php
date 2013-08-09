<?php
include_once 'ITest.php';
include_once '../Model/UserData.php';
include_once '../Model/UserManager.php';

class UserManagerTest implements ITest
{

    private function testAdd(){
      $usr = new UserData("psw","username");

      $usrManager = UserManager::GetInstance();
      $usrManager->Add($usr);
    }

    private function testValidate(){
      $usr = new UserData("psw","username");

      $usrManager = UserManager::GetInstance();
      $expected = false;
      $actual = $usrManager->Validate($usr);

      MyAssert($expected == $actual,"Validating expected false");

      $usrManager->Add($usr);
      $expected = true;
      $actual = $usrManager->Validate($usr);

      MyAssert($expected == $actual,"Validating expected true");


    }

    public function Run(){
        echo "....... Testing UserManagerTest...........\n";
        $this->testAdd();
        $this->testValidate();
    }
}

?>