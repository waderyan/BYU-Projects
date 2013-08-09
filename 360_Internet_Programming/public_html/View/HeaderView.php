<html>
	<head>
		<title>MVC - Image Rating</title>
		<link href="http://students.cs.byu.edu/~slammers/ProjectMVC/View/myStyle.css" type="text/css" rel="stylesheet">
	</head>

	<style>
		#header{
			font-size: 90%;
			border: 2px solid black;
			background-color: #585858;
			margin: 5px 20px 20px 5px;
			width: 100%;
			height: 10%;
		}

		#header h1{
			color: white;
			text-align: center;
		}

		#content{
			margin-top: 10px;
		}

		#footer{
			height: 10%;
			text-align: center;
		}

		.btn-primary{
			color: #ffffff; 
		  text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.25);
		  background-color:  #006dcc; 
		  background-image: -webkit-linear-gradient(top, #0088cc, #0044cc);
		  background-image: -o-linear-gradient(top, #0088cc, #0044cc);
		  background-image: linear-gradient(to bottom, #0088cc, #0044cc);
		  background-repeat: repeat-x;
		  border-color: #0044cc #0044cc #002a80;
		  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
		}

		.btn-large{
			padding: 11px 11px;
		  font-size: 17.5px;
		  color: white;
		  width: 23%;
		  margin: 4px;
		}

		.container {
		  margin-right: auto;
		  margin-left: auto;
		}

		.nav {
		  margin-bottom: 20px;
		  margin-left: 0;
		  list-style: none;
		  height: 10%;
		}

		.hero-unit {
		  padding: 60px;
		  margin-bottom: 30px;
		  font-size: 18px;
		  font-weight: 200;
		  line-height: 30px;
		  color: inherit;
		  background-color: #eeeeee;
		  -webkit-border-radius: 6px;
		     -moz-border-radius: 6px;
		          border-radius: 6px;
		}

		.hero-unit h1 {
		  margin-bottom: 0;
		  font-size: 60px;
		  line-height: 1;
		  letter-spacing: -1px;
		  color: inherit;
		}
	</style>

	<body>
		<div class="container">
			<div id="header">
				<h1>Image Rating</h1>
			</div>
			<div class="nav">
				<form action="../Controller/FrontController.php">
					<input class="btn-primary btn-large" type="submit" name="Home" value="Home">
					<input class="btn-primary btn-large" type="submit" name="Popular" value="Popular">
					<input class="btn-primary btn-large" type="submit" name="Recent" value="Recent">
					<input class="btn-primary btn-large" type="submit" name="Submit" value="Submit">
				</form>
			</div>
		</div>