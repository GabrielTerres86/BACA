<?php
	/*!
	 * FONTE        : manter_rotina_excluir_lancamento.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 05/10/2015
	 * OBJETIVO     : Rotina para excluir os lançamentos de pagamento do INSS
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"E")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cddotipo = isset($_POST["cddotipo"]) ? $_POST["cddotipo"] : "E";
	$cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : 0;
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$nrdocmto = isset($_POST["nrdocmto"]) ? $_POST["nrdocmto"] : 0;

	if ( $cddotipo == "E") {
		
		if ( $cdcooper == 0 ||  $nrdconta == 0 || $nrdocmto == 0 ) {
			exibirErro('error','Lan&ccedil;amento n&atilde;o identificado para excluir.','Alerta - Ayllos','',false);
		}
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcopcon>".$cdcooper."</cdcopcon>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= "   <cddotipo>".$cddotipo."</cddotipo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PRCINS", "PROCESSA_EXCLUIR_LANCAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	} 
	
	if($cddotipo == 'T'){
		exibirErro('inform','Exclus&atilde;o processada com sucesso.','Alerta - Ayllos','estadoInicial();',false);
	}else{
		exibirErro('inform','Exclus&atilde;o processada com sucesso.','Alerta - Ayllos','buscarLancamentoExcluir();',false);
	}
?>