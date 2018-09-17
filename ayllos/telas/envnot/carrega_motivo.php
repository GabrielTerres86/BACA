<?php
	/*!
	 * FONTE        : carrega_motivo.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 12/09/2017
	 * OBJETIVO     : Arquivo para carregar informações de motivos
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
	
	$cdorigem = (isset($_POST['cdorigem'])) ? $_POST['cdorigem'] : 0;
	
	if($cdorigem == "" || $cdorigem == 0){
		exibeErro("Informe a origem!");
	} 
	
	$xml  = '';
	$xml .= '<Root><Dados><cdorigem_mensagem>'.$cdorigem.'</cdorigem_mensagem></Dados></Root>';
	
	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResult = mensageria($xml, 'TELA_ENVNOT', 'LISTA_MOTIVO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		die();
	}
	
	$json = array();
	$registros = $xmlObjeto->roottag->tags[0]->tags[1]->tags;
	$qtRegistros = count($registros);
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script>';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		echo '</script>';
		exit();
	}
	
	if($qtRegistros > 1){
		$json[] = array('cdmotivo' => 0, 'dsmotivo' => '-- SELECIONE --');
	}
	
	for ($i = 0; $i < $qtRegistros; $i++){ 
		$json[] = array('cdmotivo' => getByTagName($registros[$i]->tags,'cdmotivo_mensagem'), 'dsmotivo' => utf8_encode(trim(getByTagName($registros[$i]->tags,'dsmotivo_mensagem'))));
	}
		
	echo json_encode($json);
	
?>