<?php
include_once 'ITest.php';
include_once '../Model/ImageData.php';

class ImageDataTest implements ITest
{

    private function testConstructor(){
       $title = "ImageTitle";
       $description = "image that has lots of really cool things on it";
       $path = "/path/to/nowhere";

       $tooLongTitle = "akljdfkl;ajdfkla;sjdfkl;asjdfkad;sjfkasdjfk;asjdkfjaskldfjas";
       $tooLongDescription = "akdfjkl;adjsfkl;ajsdfkl;jakl;dfjakl;sdfjkl;afjkl;asjfkl;asjdfk;jaskl;dfjakl;sdfjaklsjfak;jfkdasjfk;adjk;fjaskl;dfjakl;dfjkaljdfk;asjfdk;asjfk;ajsdfk;ajsdk;fjaskdf;jaksl;dfjaksd;fjkasjdaklfjkasdfj;kasdjfkl;asdjfklasjfk;jasdkl;fjaskl;dfjakl;sfjdkl;asdjfkl;ajfdkl;asjdfkl;ajsdfk;jaskl;dfjaskl;dfjakl;dfjakl;sjdfkl;asfjkl;asjdfkl;ajsfkl;asjk;dlfja;sdkfjak;sdfjaksdfjakl;sdfjkl;sa";

       $nullTitle = null;
       $nullDescription = null;
       $nullPath = null;

       $emptyTitle = "";
       $emptyDescription = "";
       $emptyPath = "";

       try{
       		$img = new ImageData($title,$description,$path);
       } catch(Exception $e){
       	MyAssertFail("constructor should not fail");
       }

      try{
       		$img = new ImageData($tooLongTitle,$description,$path);
       		MyAssertFail("exception should be thrown  for long title");
       } catch(Exception $e){

       	
       }

       try{
       		$img = new ImageData($title,$tooLongDescription,$path);
       		MyAssertFail("exception should be thrown for too long description");
       } catch(Exception $e){

       }

       try{
       		$img = new ImageData($nullTitle,$description,$path);
       		MyAssertFail("exception should be thrown for null title");
       } catch(Exception $e){

       }

       try{
       		$img = new ImageData($emptyTitle,$description,$path);
       		MyAssertFail("exception should be thrown for empty title");
       } catch(Exception $e){

       }

       try{
       		$img = new ImageData($title,$emptyDescription,$path);
       		MyAssertFail("exception should be thrown for empty description");
       } catch(Exception $e){

       }

       try{
       		$img = new ImageData($title,$nullDescription,$path);
       		MyAssertFail("exception should be thrown for null description");
       } catch(Exception $e){

       }

       try{
       		$img = new ImageData($title,$description,$emptyPath);
       		MyAssertFail("exception should be thrown for empty path");
       } catch(Exception $e){

       }

    }

    public function Run(){
        echo "....... Testing ImageDataTest...........\n";
        $this->testConstructor();
    }
}

?>