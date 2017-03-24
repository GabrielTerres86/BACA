<?php
/* !
 * FONTE        : busca_operadoras.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 10/03/2017
 * OBJETIVO     : Busca as operadoras disponiveis para a recarga e seus respectivos valores
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

if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $_POST['cddopcao'])) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();
}

$xmlreq = new XmlMensageria();

$xmlResult = mensageria($xmlreq, "TELA_RECCEL", "BUSCA_OPERADORAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
   $xmlObj = getObjectXML($xmlResult);	
   
// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
    exit();
}

if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	    
    $xml = simplexml_load_string($xmlResult);
    $json =  json_encode($xml);
    echo $json;
}
?>                