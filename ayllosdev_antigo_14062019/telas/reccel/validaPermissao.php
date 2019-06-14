<?
/*!
 * FONTE        : validaPermissao.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 06/03/2017
 * OBJETIVO     : Validar permissão das opções da tela
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
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);		
		exit();
	}

	// Para opção R devemos validar se o canal possui permissão para recarga
	if ($cddopcao == 'R'){
		$xml = new XmlMensageria();

		$xmlResult = mensageria($xml, "TELA_RECCEL", "VERIFICA_SITUACAO_CANAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);	
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',utf8_encode($msg),'Alerta - Ayllos','',false);	
			exit();
		}

		// Obtém situação do canal
		$flgsitrc = $xmlObj->roottag->tags[0]->tags[0]->cdata;

		if ($flgsitrc != 1){
			exibirErro('error','Opera&ccedil;&atilde;o n&atilde;o dispon&iacute;vel.','Alerta - Ayllos','$(\'#cddopcao\', \'#frmCab\').focus();',false);	
			exit();
		}
	}
	echo 'btnContinuar();';
?>