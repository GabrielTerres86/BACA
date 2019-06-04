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
            <div class="col-6">

                <?php

                    /* 
                     * P A N I C !
                     * Página para ativar ou desativar o modo de manutenção do sistema
                     * Quando ativo, o sistema inteiro deixa de ser acessível
                     * 
                     * 
                     */

                    if (file_exists('panic.status.php')) {
    
                        //chmod("panic.status.php",0666);

                        // lê conteúdo do arquivo
                        $panic_file_content = file_get_contents('panic.status.php');
                        
                        // verifica status
                        if ($panic_file_content === $secret_crypt) {
                            $panic = true;
                        } else { 
                            $panic = false;
                        }
    
                    } else {

                        // se o arquivo não existe
                        $panic = false;
                        echo 'arquivo de configuração do modo de manutenção não existe!';
                        die();
                    }

                    // verifica se o form foi enviado
                    if (isset($_REQUEST['panic'])) {

                        // recebe a credencial
                        $panic_request  = $_REQUEST['panic'];

                        // criptografa a credencial
                        $panic_request_crypt = hash('sha512',$panic_request);

                        // valida a credencial digitada
                        if ($panic_request_crypt === $secret_crypt) {

                            if ($panic === false) {

                                $panic_file = fopen("panic.status.php", "w") or die("Unable to open file!");
                                fwrite($panic_file, $secret_crypt);
                                fclose($panic_file);
                                
                                $panic = true;
                                echo '<h5 class="text-success">Credencial correta.<br> O sistema foi desativado</h5>';

                            } else {

                                $panic_file = fopen("panic.status.php", "w") or die("Unable to open file!");
                                fwrite($panic_file, ' ');
                                fclose($panic_file);

                                $panic = false;
                                echo '<h5 class="text-success">Credencial correta.<br> O sistema foi ativado</h5>';
                            }
                        } else {
                            echo '<h5 class="text-danger">Sua credencial não esta correta</h5>';
                        }

                    }
                ?>

           </div>
        </div>

        <div class="row h-100 justify-content-center align-items-center">
            <div class="col-2 text-center">

                <p>
                    <h5>
                        Status<br>

                        <?php
                        if ($panic === true) {
                            echo '<span class="badge badge-pill badge-danger">sistema inativo</span>';
                        } else {
                            echo '<span class="badge badge-pill badge-success">sistema ativo</span>';
                        }
                        ?>
                    </h5>
                </p>
                
           </div>
        </div>

        <div class="row h-100 justify-content-center align-items-center">
            <div class="col-6">
                
                <img src="../public/assets/images/logos/coop0.png"> <br>

                <h4>Modo de manutenção</h4>

                <?php

                // verifica se o modo de manutenção esta ativo!

                if ($panic === true) {
                    echo 'Entre com a credencial para ATIVAR o sistema';
                } else {
                    echo 'Entre com a credencial para DESATIVAR o sistema';
                }

                ?>
               
           </div>
        </div>

        <div class="row h-100 justify-content-center align-items-center">
            <div class="col-2">
                
                <form method="POST">
                  <div class="form-group">
                    <br>
                    <input type="password" class="form-control bg-secondary" name="panic">
                  </div>

                    <?php

                    // verifica se o modo de manutenção esta ativo!

                    if ($panic === true) {
                        echo '<button type="submit" class="btn btn-primary">Ativar o sistema</button>';
                    } else {
                        echo '<button type="submit" class="btn btn-primary">Desativar o sistema</button>';
                    }

                    ?>
                  
                </form>

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
