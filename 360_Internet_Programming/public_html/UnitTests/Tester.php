<?php

	//Runs all unit tests

	include_once 'ImageDataTest.php';
	include_once 'UserDataTest.php';
	include_once 'UserManagerTest.php';

	$tests = array();
	$tests[] = new ImageDataTest();
	$tests[] = new UserDataTest();
	$tests[] = new UserManagerTest();

	foreach($tests as $test){
		$test->Run();
	}
	
?>