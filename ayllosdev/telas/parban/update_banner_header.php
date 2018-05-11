<?php 
	
	/* !
	 * FONTE        : upload_manual.php
	 * CRIACAO      : Gustavo Meyer
	 * DATA CRIACAO : 28/02/2018
	 * OBJETIVO     : Rotina para salvar informações de mensagens manuais da tela ENVNOT
	 * --------------
	 * ALTERCOES   : 
	 * -------------- 
	**/
	
	session_cache_limiter("private");
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Array com os tipos de erros de upload do PHP 
	$_UP['erros'][0] = 'Não houve erro'; 
	$_UP['erros'][1] = 'O arquivo no upload é maior do que o limite do PHP';
	$_UP['erros'][2] = 'O arquivo ultrapassa o limite de tamanho especifiado no HTML';
	$_UP['erros'][3] = 'O upload do arquivo foi feito parcialmente'; 
	$_UP['erros'][4] = 'Não foi feito o upload do arquivo';
	

	// Captura as informações enviadas via POST

	$dsbannerorder = (isset($_POST['dsbannerorder'])) ? $_POST['dsbannerorder'] : ''; 
	$nrsegundos_transicao = (isset($_POST['nrsegundos_transicao'])) ? $_POST['nrsegundos_transicao'] : "";
	$intransicao = ($nrsegundos_transicao != "" && $nrsegundos_transicao !="0") ? 1 :0;
 	$cdCanal = (isset($_POST['cdcanal'])) ? $_POST['cdcanal'] : 10; 
		
	// VARIAVEIS PARA BD
	$glbvars["cdcooper"] = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$glbvars["cdagenci"] = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$glbvars["nrdcaixa"] = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : 0;
	$glbvars["idorigem"] = (isset($_POST['idorigem'])) ? $_POST['idorigem'] : 1;
	$glbvars["cdoperad"] = (isset($_POST['cdoperad'])) ? $_POST['cdoperad'] : "0";
		
	
	
	$xml  = '';
	$xml .= '<Root><Dados>';
	$xml .= '<cdcanal>'.$cdCanal.'</cdcanal>';
	$xml .= '<dsbannerorder>'.$dsbannerorder.'</dsbannerorder>';
	$xml .= '<intransicao>'.$intransicao.'</intransicao>';
	$xml .= '<nrsegundos_transicao>'.$nrsegundos_transicao.'</nrsegundos_transicao>';
	$xml .= '</Dados></Root>';
	// Enviar XML de ida e receber String XML de resposta
	$xmlResultMantemMsgManu = mensageria($xml, 'TELA_PARBAN','TELA_BANNER_MANTEM_ORDEM', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoMantemMsgManu = getObjectXML($xmlResultMantemMsgManu);

	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjetoMantemMsgManu->roottag->tags[0]->name) && strtoupper($xmlObjetoMantemMsgManu->roottag->tags[0]->name) == "ERRO") {
		gerarErro($xmlObjetoMantemMsgManu->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exit;
	}else{
		echo "parent.framePrincipal.eval(\"showError('inform','Itens atualizados com sucesso!','Alerta - Ayllos','hideMsgAguardo(); ');\");";
		exit;
	}		
	
	function gerarErro($dserro){
		echo "parent.framePrincipal.eval(\"showError('error','".$dserro ."','Alerta - Ayllos','hideMsgAguardo();');\");";
		exit;
	}
?>