<?php

class DAO
{
    // Fields

    private $con;
    private $db;
    private $dbh;

    // Constructor

    /**
    * Constructor initializes database connection
    */
    public function __construct(){    
    }

    // Private Methods

    private function Connect(){
        $host = 'paintball.cs.byu.edu';
        $port = 5556;
        $user = 'CS360';
        $passwd = 'CS360';
        $dbname = 'slammersDB';

        try
        {
            //$this->con = mysql_connect($host, $user, $passwd);
            //$this->db = mysql_select_db($dbname, $this->con);

            //if (!$this->db) { 
            //    die("Database selection failed:: " . mysql_error()); 
            //} 
            $dsn = "mysql:host=".$host.";port=".$port.";dbname=".$dbname;
            $this->dbh = new PDO($dsn, $user, $passwd);

        } catch (PDOException $e){
            echo "Exception: " . $e->getMessage();
            die("Unable to connect to database with dsn=[$dsn]: ". $e->getMessage());

        }

        echo 'Connected Succesfully';

        //$this->CheckForErrorCon();
    }

    /**
    * Closes the database
    */
    private function Close(){
        mysql_close($this->con);
    }

    /**
    * Checks for an error in the connection
    */
    private function CheckForErrorCon(){
         if(mysql_errno() != 0)
            throw new Exception("Connection error!");
    }

    private function CheckCon(){
        return mysql_ping($this->con);
    }


    // Operations

    /**
    * Inserts an image into the database
    */
    public function InsertImage($img){
        $cmd = sprintf("insert into image (title, description, path, rating, submissiondate) Values ('%s','%s','%s',%d,'%s')"
            , $img->title, $img->description
            , $img->path, $img->rating
            , $img->submissiondate);

    }

    /**
    * Updates the oldImage in the database
    * Returns true if succesful, false otherwise
    */
    public function UpdateImage($oldImg, $newImg){

    }

    /**
    * Gets all images from the database
    * Returns all images
    */
    public function GetImages(){
        $cmd = "Select * from image";

        try{
            $this->connect();

           
           $this->close();
        } catch(Exception $ex){
            echo "Exception: " . $ex->getMessage();
        }
        

        return array();
    }

    /**
    * Gets all users from the database
    * Returns an array of users
    */
    public function GetUsers(){
        $cmd = "Select * from user";

        return array();
    }

    /**
    * Inserts a user into the database
    */
    public function InsertUser($usr){

        $cmd = "insert into user (password, username) Values (?, ?)";

        
        try{
            $this->Connect();
       
            $sth = $this->dbh->prepare($cmd);
            $result = $sth->execute(array($usr->_password,$usr->_username));

            if(!$result){
                $message  = 'Invalid query: ' . mysql_error() . "\n";
                $message .= 'Whole query: ' . $cmd;
                die($message);
            }

            $this->Close();
        } catch(Exception $ex){
            echo "Exception: " . $ex->getMessage();
        }    
        
    }
    
}

?>

