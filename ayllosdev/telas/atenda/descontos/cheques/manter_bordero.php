<?php
	/*!
	 * FONTE        : manter_bordero.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 21/11/2016
	 * OBJETIVO     : Rotina para manter bordero de desconto de cheque
	 * --------------
	 * ALTERAÇÕES   : 26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).
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
	$nrdolote = !isset($_POST["nrborder"]) ? 0  : $_POST["nrborder"];
	$cddopcao = !isset($_POST["cddopcao"]) ? "" : $_POST["cddopcao"];
	$dscheque = !isset($_POST["dscheque"]) ? "" : $_POST["dscheque"];
	$dscheque_exc = !isset($_POST["dscheque_exc"]) ? "" : $_POST["dscheque_exc"];
	$executandoProdutos = $_POST['executandoProdutos'];
	
	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
	if ($dscheque === "" && $dscheque_exc === "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= "   <nrdolote>".$nrdolote."</nrdolote>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <dscheque>".$dscheque."</dscheque>";
	$xml .= "   <dscheque_exc>".$dscheque_exc."</dscheque_exc>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "MANTER_BORDERO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		$msgErro = ($cddopcao == 'I') ? 'Border&ocirc; inclu&iacute;do com sucesso' : 'Border&ocirc; alterado com sucesso';
		
		//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
		if ($executandoProdutos == 'true') {
			
			exibirErro('inform',$msgErro,'Alerta - Aimaro','encerraRotina(true);',false);
			
		}else{
		
		exibirErro('inform',$msgErro,'Alerta - Aimaro','voltaDiv(3,2,4,\'DESCONTO DE CHEQUES - BORDERÔS\'); carregaBorderosCheques();',false);
		
		}
		
	}	
?>
