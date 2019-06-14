<?php

/***********************************************************************
  Fonte: imprimir_consulta_sms_csv.php                                              
  Autor: Adriano Nagasava - Supero
  Data : Setembro/2018                       �ltima Altera��o: - 		   
	                                                                   
  Objetivo  : Gerar o CSV dos SMS.              
	                                                                 
  Altera��es: 
  
***********************************************************************/
	session_cache_limiter("private");
	session_start();
		
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

	/*if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['cddopcao'])) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}*/
	
	$c 			= array('.', '-'); 
	
	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$cddopcao	= $_POST['cddopcao'];
	$tprelato	= $_POST['tprelato'];
	$inidtmvt	= $_POST['inidtmvt'];
	$fimdtmvt	= $_POST['fimdtmvt'];
	$cdstatus	= $_POST['cdstatus'];
	$nrdconta	= str_ireplace($c, '',$_POST['nrdconta']);	
	$nmprimtl	= $_POST['nmprimtl'];
	$cdagencx	= $_POST['cdagenci'];
	$inserasa	= $_POST['inserasa'];
    $instatussms = $_POST['inStatusSMS'];
    
    //  Para relatorio 7 - Analitico de SMS
    if ($tprelato == 7) { 


	if (trim($nrdconta) == "") {
		?><script language="javascript">alert('Favor informar a conta a ser filtrada.');</script><?php
		exit();	
	}

        $xml = new XmlMensageria();
        $xml->add('nrdconta',$nrdconta);
        $xml->add('dtiniper',$inidtmvt);
        $xml->add('dtfimper',$fimdtmvt);
        $xml->add('dsiduser',$dsiduser);
        $xml->add('instatus',$instatussms);

        $xmlResult = mensageria($xml, "COBRAN", "GERA_SMS_CSV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
			exit();
		}
		
		$nmarqcsv = $xmlObject->roottag->tags[0]->tags[0]->cdata;
		visualizaCSV($nmarqcsv);

    } else {
		?><script language="javascript">alert('Opera��o dispon�vel apenas para a op��o 7 - Anal�tico de SMS.');</script><?php
	}
		

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
	    echo '<script>alert("'.$msgErro.'");</script>';	
	    exit();
	}
?>