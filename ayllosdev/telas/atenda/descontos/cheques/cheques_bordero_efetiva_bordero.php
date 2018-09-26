<?php 

	/************************************************************************
	 Fonte: cheques_bordero_efetiva_bordero.php
	 Autor: Lucas Reinert
	 Data : Dezembro/2016                Última Alteração: 31/05/2017
	                                                                  
	 Objetivo  : Efetivar/liberar borderô de desconto de cheques
	                                                                  	 
	 Alterações: 31/05/2017 - Ajuste para verificar se possui cheque custodiado
                              no dia de hoje. 
                              PRJ300- Desconto de cheque. (Odirlei-AMcom)
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L")) <> "") {
		exibeErro($msgError);		
	}
		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;	
	$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;	
	$cdopcolb = (isset($_POST['cdopcolb'])) ? $_POST['cdopcolb'] : ' ';	
    $flresghj = (isset($_POST["flresghj"])) ? $_POST["flresghj"] : 0;
	
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= "   <cdopcolb>".$cdopcolb."</cdopcolb>";
    $xml .= "   <flresghj>".$flresghj."</flresghj>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "EFETIVA_DESCONTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		exit();
	}else{
		$msgErro = 'Border&ocirc; liberado com sucesso';
		exibirErro('inform',$msgErro,'Alerta - Aimaro','carregaBorderosCheques();',false);
	}
	
?>