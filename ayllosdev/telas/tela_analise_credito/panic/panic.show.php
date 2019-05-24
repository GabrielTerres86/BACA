<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

setlocale(LC_ALL, "pt_BR", "pt_BR.iso-8859-1", "pt_BR.utf-8", "portuguese");
header("Content-Type: text/html; charset=UTF-8",true);

require_once '../public/vendor/autoload.php';
require_once 'panic.secret.php';

?>
<!doctype html>
<html lang="pt-br">
  <head>

    <meta charset="UTF-8">
    <meta name="viewport"   content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <link rel="stylesheet"  href="../node_modules/bootstrap/dist/css/bootstrap.min.css">
    <link rel="stylesheet"  href="../node_modules/@fortawesome/fontawesome-free/css/all.min.css">
    <link rel="stylesheet"  href="../public/assets/css/style.css">
    <link rel="stylesheet"  href="../public/assets/css/custom.css">
    <link rel="icon"        href="../public/assets/images/favicon-96x96.png" />

    <title>Panic! Manutenção</title>
  </head>
  <body>
    <div id="container" class="text-center">
        
        <br><br>

        <div class="row h-100 justify-content-center align-items-center">
            <div class="col-2 text-center">
                <p>
                    <h5>
                        <span class="badge badge-pill badge-danger">sistema em manutenção</span>
                    </h5>
                </p>
           </div>
        </div>

        <div class="row h-100 justify-content-center align-items-center">
            <div class="col-6">
                
                <img src="../public/assets/images/logos/coop0.png"> <br>
               
           </div>
        </div>
    </div>

    <script src="../node_modules/jquery/dist/jquery.min.js"></script>
    <script src="../public/assets/js/popper.min.js"></script>
    <script src="../public/assets/js/off-canvas.js"></script>
    <script src="../public/assets/js/misc.js"></script>

    <script src="../public/assets/js/functions.js"></script>
    <script src="../public/assets/js/panic.js"></script>

    <script src="../public/assets/js/plugins/select2.full.min.js"></script>

  </body>
</html>                
