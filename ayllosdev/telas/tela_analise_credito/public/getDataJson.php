<?php
/* 
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
*  
*  Esta tela exibe o json que foi gerado a partir do XML
* 
*/

    header("Content-type: text/html; charset=utf-8");
    ini_set('session.cookie_domain', '.cecred.coop.br' );
    session_start();

    // verifica se existe um token
    if (isset($_GET['token'])) {
    
        // recebe o token
        $token = $_GET['token'];

        // verifica se existe uma sessao com o nome desse token
        if (isset($_SESSION[$token])) {
    
            echo '<pre style="font-size:11px;">';
            print_r($_SESSION[$token]);
            echo '</pre>';
            
        } else {   

            // sem sessao do token indicado
            echo 'sem acesso';

        }

    } else {

        // sem token
        echo 'sem acesso';

    }

?>