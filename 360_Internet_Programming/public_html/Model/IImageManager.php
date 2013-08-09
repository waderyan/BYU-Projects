<?php

/**
* Interface for Image Manager
*/
interface IImageManager{

	/**
	* Inserts an image 
	* CanInsertImage(imageData) == true
	* Returns void
	* Equivalent to:
	* Adding data to list of images
	* Insert image into database
	*/
	public function Add($imageData);

	/**
	* Can Insert Image checks to see if an image is valid 
	* to insert
	* Returns true if valid insert, false otherwise
	* imageData != null
	*/
	public function CanAdd($imageData);

	/**
	* Gets the ten most popular images
	* Returns 10 most popular images based on rating
	* Equivalent to:
	* GetImages() from database
	* Query all images to get the ten most popular
	*/
	public function GetPopular();

	/**
	* Gets the ten most recent images
	* Returns 10 most recent images based on date
	* Equivalent to:
	* GetImages() from database
	* Query all images to get the ten most recent
	*/
	public function GetRecent();

	/**
	* Updates the rating of an image
	* CanRateImage(img) == true
	* Returns void
	* Equivalent to:
	* Update rating on imageData
	* Send updated image to database
	*/
	public function Rate($imageData,$rating);


	/**
	* Determines if an image can be rated
	* imageData != null
	* Returns true if canRate, false otherwise
	*/
	public function CanRate($imageData);

}

?>