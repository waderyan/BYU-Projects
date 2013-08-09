<?php
session_start();

main();

function main(){
    $control = new Controller();
    $control->ProcessRequest();
    $control->ChangeView();

}

class Controller{

    function ProcessRequest(){
        if (isset($_SESSION['CurrentPage'])) { 

            switch ($_SESSION['CurrentPage']) 
            { 
                case 'Home': 
                    echo "Processing home";
                    break; 
                case 'Popular': 
                    echo "Processing Popular";
                    break; 
                case 'Recent': 
                    echo "Processing recent";
                    break; 
                case 'Submit': 
                    echo "Processing submit";
                    break; 
            } 
        }  
    }

    function ChangeView(){

        if (isset($_REQUEST['Popular'])) {
             include ('../View/PopularView.php');
        }
        elseif (isset($_REQUEST['Recent'])) {
             include ('../View/RecentView.php');
        }
        elseif (isset($_REQUEST['Submit'])) {
             include ('../View/SubmitView.php');
        }
        else{
            include ('../View/HomeView.php');
        }   
    }

}

?>

