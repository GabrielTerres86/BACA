<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

setlocale(LC_ALL, "pt_BR", "pt_BR.iso-8859-1", "pt_BR.utf-8", "portuguese");
header("Content-Type: text/html; charset=UTF-8",true);

$isLocalhost = $_SERVER['SERVER_NAME'] === 'localhost' ? true : false;

//DEFINIR COMO TRUE QUANDO ESTIVER DENTRO DO SERVIDOR
define('AUTENTICA_USUARIO',!$isLocalhost);

require_once 'vendor/autoload.php';

$configCore = array(
    'env' => true, //Ambiente: env -> true |prod -> false
    'header' => true, //Imprimir header
    'footer' => true, //Imprimir footer
    'localhost' => $isLocalhost, //Indica se é localhost ou ambiente de prod || DEFINIR COMO FALSE QUANDO ESTIVER DENTRO DO SERVIDOR
    'debugMensageria' => false, //TRUE -> Coloca na tela o retorno da mensageria | false -> desliga (only webApiCall())
    'getParameters' => $_GET
);

if(AUTENTICA_USUARIO){
    if(!$configCore['localhost']) {
        include('chamadas/chamadas.php');
        $_SESSION['configCore'] = $configCore;
        $_GET['tipoChamada'] = "GET_XML";
        if(!isset($_SESSION['params'])){
            echo 'Sistema não está autenticado.';
            exit();
        }
        $dataPost = (object)$_SESSION['params'];
        $getXml = getXml();
        $_SESSION['xml'] = $getXml;
    }
}

// echo '<pre>';
// var_dump($_SESSION);
// die(' teste de sistema');

$database 	= new Database();
$core 		= new Core($configCore);