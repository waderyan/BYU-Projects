<?php
include_once 'IImangeManager.php';

/**
*  Class to manage all image operations
*  Singleton implementation
*/
class ImageManager implements IImangeManager{

	// Constructor

	private static $instance;

	public static function GetInstance(){
		if($instance == null)
			$instance = new ImageManager();

		return $instance;
	}

	private function __construct(){
		
	}

	/**
	* Loads all images from the database
	*/
	private function LoadImages(){
		try{
			dao = new DAO();
			$images = dao->GetImages();
		} catch(Exception $ex){
			echo "ERROR getting images from database! " . $ex->getMessage();
		}

		return $images;
	}

	// IImageManager Operations

	//Override
	public function Add($imageData){
		if(!$this->CanAdd($imageData))
			throw new Exception("Cannot Add imageData, CanAdd() == false");

		try{
			$dao = new DAO();
			$dao->InsertImage($imageData);

		} catch(Exception $ex){
			throw new Exception($ex->getMessage());
		}
	}

	//Override
	public function CanAdd($imageData){
		if($imageData == null)
			return false;

		return true;
	}

	//Override
	public function GetPopular(){
		$images = $this->LoadImages();
		usort($images, "compareByRating");
		return $images;
	}

	//Override
	public function GetRecent(){
		$images = $this->LoadImages();
		usort($images, "compareByDate");
		return $images;
	}

	//Override
	public function Rate($imageData,$rating){
		$oldImage = $imageData;
		$newImage = new ImageData($imageData->title
							, $imageData->description
							, $imageData->path);
		$newImage->rating = $oldImage->rating + $rating;

		try{
			$dao = new DAO();
			$dao->UpdateImage($oldImage,$newImage);

		} catch(Exception $ex){
			echo "ERROR rating image" . $ex->getMessage();
		}
	}

	//Override
	public function CanRate($imageData){
		if($imageData == null)
			return false;

		return true;	
	}

	// Compareres
	// -1 means ob1 < obj2
	// 1 means ob1 > obj2
	// 0 means ob1 == ob2

	/**
	* Compares images by submission date
	*/
	public static function compareByDate($img1, $img2){
        return $img1->submissionDate - $img2->submissionDate;
    }

    /**
    * Compares images
    */
    public static function compareByRating($img1, $img2){
        return $img1->rating - $img2->rating;
    }


}

?>