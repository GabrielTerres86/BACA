<?php
	/*!
	* FONTE        : buscar_mensagens.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Agosto/2018
	* OBJETIVO     : Rotina para realizar a busca das mensagens
	* --------------
	* ALTERAÇÕES   : 
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	$nrseq_mensagem_xml   = isset($_POST["nrseq_mensagem_xml"])   ? $_POST["nrseq_mensagem_xml"]   : 0;
	$cdcooper             = isset($_POST["cdcooper"])             ? $_POST["cdcooper"] : 0;
	$nrdconta             = isset($_POST["nrdconta"])             ? $_POST["nrdconta"] : 0;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrseq_mensagem_xml>"  .$nrseq_mensagem_xml.  "</nrseq_mensagem_xml>";
	$xml .= "   <cdcooper_msg>".$cdcooper."</cdcooper_msg>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_SPBMSG", "SPBMSG_REPROCESSA_MSG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = simplexml_load_string($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if($xmlObj->Erro->Registro->cdcritic){	
		$msgErro = $xmlObj->Erro->Registro->dscritic;
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);
	}

	$mensagens = $xmlObj;
	
	$log = '';
	foreach ($mensagens as $mensagem) {
		$log .= $mensagem . '\n';
	}

	echo 'mostrarLOGReprocessa("'.$log.'")';
?>
