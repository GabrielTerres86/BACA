<?php
/* !
 * FONTE        : efetua_recarga.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 10/03/2017
 * OBJETIVO     : Efetuar recarga de celular
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */


session_cache_limiter("private");
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], 'R')) <> "") {
	exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}

$nrdconta = !isset($_POST["nrdconta"]) ? 0  : $_POST["nrdconta"];
$nrdddtel = !isset($_POST["nrdddtel"]) ? 0  : $_POST["nrdddtel"];
$nrtelefo = !isset($_POST["nrtelefo"]) ? 0  : $_POST["nrtelefo"];
$cdoperadora = !isset($_POST["cdoperadora"]) ? 0  : $_POST["cdoperadora"];
$cdproduto = !isset($_POST["cdproduto"]) ? 0  : $_POST["cdproduto"];
$vlrecarga = !isset($_POST["vlrecarga"]) ? 0  : $_POST["vlrecarga"];

$xmlReq = new XmlMensageria();
$xmlReq->add('nrdconta',$nrdconta)
       ->add('nrdddtel',$nrdddtel)
       ->add('nrtelefo',$nrtelefo)
       ->add('cdoperadora',$cdoperadora)
       ->add('cdproduto',$cdproduto)
       ->add('vlrecarga',$vlrecarga); 

$xmlResult = mensageria($xmlReq, "TELA_RECCEL", "EFETUA_RECARGA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
   $xmlObj = getObjectXML($xmlResult);	
   
// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msg = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
    exibirErro('error',$msg,'Alerta - Ayllos','btnVoltar();',false);
}
if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	    
    $dsnsuope = $xmlObj->roottag->tags[0]->tags[0]->cdata;
    exibirErro('inform','Recarga de celular efetuada com sucesso. <br> NSU Operadora: '. $dsnsuope,'Alerta - Ayllos','btnVoltar();',false);
}

?>                