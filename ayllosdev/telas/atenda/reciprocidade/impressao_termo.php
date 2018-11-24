<?php

/***********************************************************************
  Fonte: impressao_termo.php                                               
  Autor: Gabriel                                                  
  Data : Marco/2011                       �ltima Altera��o: 04/07/2012 		   
	                                                                   
  Objetivo  : Gerar o PDF do termo da rotina de COBRANCA da ATENDA.              
	                                                                 
  Altera��es: 26/07/2011 - Incluir a impressao de Cobranca registrada
						   (Gabriel).
						   
			  04/07/2012 - Retirado funcao exibeErro(). (Jorge)

			  28/12/2015 - Novo contrato cobran�a registrada (Daniel)
  
***********************************************************************/

session_cache_limiter("private");
session_start();
	
// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");	
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");	


// Verifica se tela foi chamada pelo m�todo POST
isPostMethod();

// Recebe o nome do PDF
$nrdconta = $_POST["nrdconta"];
$dsdtitul = $_POST["dsdtitul"];
$flgregis = $_POST["flgregis"];
$nmdtest1 = $_POST["nmdtest1"];
$cpftest1 = $_POST["cpftest1"];
$nmdtest2 = $_POST["nmdtest2"];
$cpftest2 = $_POST["cpftest2"];
$nrconven = $_POST["nrconven"];
$tpimpres = $_POST["tpimpres"];
$idrecipr = $_POST["idrecipr"];

$dsiduser =  session_id();

if ($flgregis == 'yes' ) {

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idseqttl>1</idseqttl>";
	$xml .= "   <flgregis>".$flgregis."</flgregis>";
	$xml .= "   <nmdtest1>".$nmdtest1."</nmdtest1>";
	$xml .= "   <cpftest1>".$cpftest1."</cpftest1>";
	$xml .= "   <nmdtest2>".$nmdtest2."</nmdtest2>";
	$xml .= "   <cpftest2>".$cpftest2."</cpftest2>";
	$xml .= "   <dsiduser>".$dsiduser."</dsiduser>";
	$xml .= "   <dsdtitul>".$dsdtitul."</dsdtitul>";
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "   <idcalculo_reciproci>".$idrecipr."</idcalculo_reciproci>";
	$xml .= "   <tpimpres>".$tpimpres."</tpimpres>"; // 1 - Ades�o  2 - Cancelamento
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// craprdr / crapaca 
	$xmlResult = mensageria($xml, "SSPC0002", "IMPTERMO_RECIPROCI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
	}

	//Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjeto->roottag->cdata;

	//Chama fun��o para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);	

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
	}
} else {	
	/* Montar o Xml */
	
	$xmlImpressaoTermo  = "";
	$xmlImpressaoTermo .= "<Root>";
	$xmlImpressaoTermo .= " <Cabecalho>";
	$xmlImpressaoTermo .= "  <Bo>b1wgen0082.p</Bo>";
	$xmlImpressaoTermo .= "  <Proc>obtem-dados-adesao</Proc>";
	$xmlImpressaoTermo .= " </Cabecalho>";
	$xmlImpressaoTermo .= " <Dados>";
	$xmlImpressaoTermo .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlImpressaoTermo .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlImpressaoTermo .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlImpressaoTermo .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlImpressaoTermo .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlImpressaoTermo .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlImpressaoTermo .= "	  <nrdconta>".$nrdconta."</nrdconta>";
	$xmlImpressaoTermo .= "   <idseqttl>1</idseqttl>";
	$xmlImpressaoTermo .= "   <flgregis>".$flgregis."</flgregis>";
	$xmlImpressaoTermo .= "   <nmdtest1>".$nmdtest1."</nmdtest1>";
	$xmlImpressaoTermo .= "   <cpftest1>".$cpftest1."</cpftest1>";
	$xmlImpressaoTermo .= "   <nmdtest2>".$nmdtest2."</nmdtest2>";
	$xmlImpressaoTermo .= "   <cpftest2>".$cpftest2."</cpftest2>";
	$xmlImpressaoTermo .= "   <dsiduser>".$dsiduser."</dsiduser>";
	$xmlImpressaoTermo .= "   <dsdtitul>".$dsdtitul."</dsdtitul>";
	$xmlImpressaoTermo .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlImpressaoTermo .= "   <nrconven>".$nrconven."</nrconven>";
	$xmlImpressaoTermo .= " </Dados>";
	$xmlImpressaoTermo .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlImpressaoTermo);

	$xmlObjTermo = getObjectXML($xmlResult);


	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjTermo->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjTermo->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 

	$nmarqpdf = $xmlObjTermo->roottag->tags[0]->attributes["NMARQPDF"];

	/// Chama fun��o para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);	
}
?>