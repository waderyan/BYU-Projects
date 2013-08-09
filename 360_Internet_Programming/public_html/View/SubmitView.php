<?php
	$_SESSION['CurrentPage'] = "Submit";
	include("HeaderView.php");
?>

<div class="hero-unit" id="content">
	<p> 1) Displays login form <br />
		2) Save user authentication with cookie session <br />
		3) User can select and upload an image <br />
		4) User must give the image a title (50) and description (200)
	</p>
</div>

<?php
	include("FooterView.php");
?>