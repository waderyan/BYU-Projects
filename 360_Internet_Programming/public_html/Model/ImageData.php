<?php
include '../Utilities.php';
include 'BaseData.php';

/**
* ImageData stores data for images
*/
class ImageData extends BaseData{

    //Properties

    public $title;
    public $description;
    public $path;
    public $rating;
    public $submissionDate;

    //Constructor

    /**
    * Constructor takes a title, description and path
    * Sets rating to 0 and submission date to current date
    * title cannot be longer than 50 chars
    * description cannot be longer than 200 chars
    * title, description, and path cannot be null or empty
    */
    public function __construct($title, $description, $path){
        
        if(IsNullOrEmptyString($title) 
            || IsNullOrEmptyString($description) 
            || IsNullOrEmptyString($path))
            throw new Exception('null or empty attributes not allowed');

        if(strlen($description) > 200)
            throw new Exception('description is longer than 200 chars');
        if(strlen($title) > 50)
            throw new Exception('title is longer than 50 chars');
            


        $this->title = $title;
        $this->description = $description;
        $this->path = $path;
        $this->rating = 0;

        date_default_timezone_set('America/Denver');
        $this->submissionDate = date('m/d/Y h:i:s a', time());
    }

}

?>