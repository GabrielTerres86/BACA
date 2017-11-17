 <?php  
/*!
 * FONTE        : cancelar_envio.php
 * CRIAÇÃO      : Jean Michel Deschamps
 * DATA CRIAÇÃO : 29/09/2017
 * OBJETIVO     : Rotina para cancelar envio de mensagens
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
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo(); voltar();escolheOpcao(\"C\");");';
		exit();
	}
	
	$cdmensagem = (isset($_POST['cdmensagem'])) ? $_POST['cdmensagem'] : '';
	
	if(trim($cdmensagem) == ""){
		exibeErro("Op&ccedil;&atilde;o Inv&aacute;lida, informe a mensagem a ser cancelada!");
		die();
	}
					
	$xml  = '';
	$xml .= '<Root><Dados>';
	$xml .= '<cdmensagem>'.$cdmensagem.'</cdmensagem>';
	$xml .= '</Dados></Root>';

	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResultCancelaEnvio = mensageria($xml, 'TELA_ENVNOT','CANCELA_ENVIO_PUSH', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoCancelaEnvio = getObjectXML($xmlResultCancelaEnvio);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjetoCancelaEnvio->roottag->tags[0]->name) && strtoupper($xmlObjetoCancelaEnvio->roottag->tags[0]->name) == "ERRO") {
		exibeErro(str_replace("'","",$xmlObjetoCancelaEnvio->roottag->tags[0]->tags[0]->tags[4]->cdata));
		die();
	}else{
		exibeErro("Envio cancelado com sucesso!");
		die();
	}
	
?>