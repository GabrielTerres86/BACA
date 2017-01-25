<?php

/***********************************************************************
  Fonte: impressao_serv_sms.php                                               
  Autor: Odirlei Busana - AMcom
  Data : Outubro/2016                       Última Alteração:
	                                                                   
  Objetivo  : Gerar o PDF do termo de adesao ou cancelamento do serviço de SMS
	                                                                 
  Alterações: 
  
***********************************************************************/

session_cache_limiter("private");
session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");	
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");	

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Recebe o nome do PDF
$nrdconta    = $_POST["nrdconta"];
$cddopcao    = trim($_POST["cddopcao"]);
$idcontrato  = trim($_POST["idcontrato"]);

$dsiduser =  session_id();

// Imprimir Contrato  de adesao
if ($cddopcao == 'IA') {    
    
    // Montar o xml de Requisicao
    $xml = new XmlMensageria();
    $xml->add('nrdconta',$nrdconta);
    $xml->add('idcontrato',$idcontrato);
    $xml->add('dsiduser',$dsiduser);   
    $nmdeacao = 'IMPRES_CTR_SERV_SMS';

// Imprimir termo de cancelamento    
} else if ($cddopcao == 'IC') {    
    
    // Montar o xml de Requisicao
    $xml = new XmlMensageria();
    $xml->add('nrdconta',$nrdconta);
    $xml->add('idcontrato',$idcontrato);
    $xml->add('dsiduser',$dsiduser);   
    $nmdeacao = 'IMPRES_CANCEL_SERV_SMS';
 
}


$xmlResult = mensageria($xml, "ATENDA", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDados  = $xmlObject->roottag->tags[0];

if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {

   $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
    }

    exibeErro($msgErro);
    exit();
}

/**** BUSCAR RETORNOS ****/
 // Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObject->roottag->tags[0]->tags[0]->cdata;

// Chama função para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);


// Função para exibir erros na tela através de javascript
function exibeErro($msgErro) { 
  echo '<script>alert("'.$msgErro.'");</script>';	
  exit();
}  
?>