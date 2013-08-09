<?php

	function MyAssert($bool,$descrip){
		if(!$bool)
			echo "Assertion Failed " . $descrip;
	}

	
	function MyAssertFail($descrip){
		echo "Failed improperly " . $descrip;
	}

?>