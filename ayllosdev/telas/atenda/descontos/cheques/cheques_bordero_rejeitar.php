<?
/*!
 * FONTE        : cheques_bordero_rejeitar.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 23/03/2017
 * OBJETIVO     : Form de exibição dos cheques para resgate do borderô
 * --------------
 * ALTERAÇÕES   :
 */
	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");


	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrborder = (isset($_POST["nrborder"])) ? $_POST["nrborder"] : 0;

	// Verifica se o n�mero do bordero � um inteiro v�lido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lida.");
	}

	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "REJEITAR_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------

	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibeErro($msgErro);
		exit();
	}

	// Esconde mensagem de aguardo
	echo 'idLinhaB = 0;';
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';

	// Recarrega os bordero
	echo 'carregaBorderosCheques();';

	// Função para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) {
		//echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		//echo '</script>';
		exit();
	}
?>
