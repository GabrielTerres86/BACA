<?php
	/*!
	 * FONTE        : cheques_bordero_conclui_analise.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 07/12/2016
	 * OBJETIVO     : Rotina para aprovar/reprovar cheques do borderô
	 * --------------
	 * ALTERAÇÕES   : 
     *
     * 001: [26/05/2017] Odirlei   (AMcom)  : Alterado para tipo de impressao 10 - Analise bordero - PRJ300 - Desconto de cheque
	 * -------------- 
	 */		

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	$nrdconta = !isset($_POST["nrdconta"]) ? 0  : $_POST["nrdconta"];
	$nrborder = !isset($_POST["nrborder"]) ? 0  : $_POST["nrborder"];
	$dscheque = !isset($_POST["dscheque"]) ? "" : $_POST["dscheque"];
	
	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
	if ($dscheque === "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= "   <dscheque>".$dscheque."</dscheque>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "APROVA_REPROVA_CHQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		$msgErro = 'Border&ocirc; analisado com sucesso';
		exibirErro('inform',$msgErro,'Alerta - Aimaro','voltaDiv(3,2,4,\'DESCONTO DE CHEQUES - BORDERÔS\'); gerarImpressao(10,2,\'no\',\'\',0);',false);
        
       
        
	}	
?>
