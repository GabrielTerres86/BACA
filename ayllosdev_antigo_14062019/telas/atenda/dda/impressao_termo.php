<?php 

/***********************************************************************
  Fonte: impressao_termo.php                                               
  Autor: Gabriel                                                  
  Data : Abril/2011                       Última Alteração: 		   
	                                                                   
  Objetivo  : Gerar o PDF dos termos da rotina de DDA da CONTAS.              
	                                                                 
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
$nrdconta = $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"];
$nmrotina = $_POST["nmrotina"];
$nmdtest1 = $_POST["nmdtest1"];
$cpftest1 = $_POST["cpftest1"];
$nmdtest2 = $_POST["nmdtest2"];
$cpftest2 = $_POST["cpftest2"];

$dsiduser = session_id();

	 
// Monta xml
$xml  = "";
$xml .= "<Root>";
$xml .= " <Cabecalho>";
$xml .= "  <Bo>b1wgen0078.p</Bo>";
$xml .= "  <Proc>".$nmrotina."</Proc>";
$xml .= " </Cabecalho>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <cdagecxa>".$glbvars["cdagenci"]."</cdagecxa>";
$xml .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "   <cdopecxa>".$glbvars["cdoperad"]."</cdopecxa>";
$xml .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xml .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";
$xml .= "	  <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "	  <nmdtest1>".$nmdtest1."</nmdtest1>";
$xml .= "	  <cpftest1>".$cpftest1."</cpftest1>";
$xml .= "	  <nmdtest2>".$nmdtest2."</nmdtest2>";
$xml .= "	  <cpftest2>".$cpftest2."</cpftest2>";
$xml .= "   <dsiduser>".$dsiduser."</dsiduser>";
$xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= " </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

$xmlObjTermo = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjTermo->roottag->tags[0]->name) == "ERRO") {
	 $msg = $xmlObjTermo->roottag->tags[0]->tags[0]->tags[4]->cdata;	
	 ?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
	 exit();
} 

$nmarqpdf = $xmlObjTermo->roottag->tags[0]->attributes["NMARQPDF"];

/// Chama função para mostrar PDF do impresso gerado no browser	 
visualizaPDF($nmarqpdf);


?>



