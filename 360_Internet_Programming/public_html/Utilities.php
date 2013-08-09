<?php

	/**
	*	Checks to see if the string is null or empty
	*/
	function IsNullOrEmptyString($str){
		return (!isset($str) || trim($str)==='');
	}

?>