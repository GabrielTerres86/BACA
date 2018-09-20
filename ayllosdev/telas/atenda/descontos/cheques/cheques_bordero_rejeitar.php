<?
/*!
 * FONTE        : cheques_bordero_rejeitar.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 23/03/2017
 * OBJETIVO     : Form de exibição dos cheques para resgate do borderô
 * --------------
 * ALTERAÇÕES   : 31/05/2017 - Ajuste para verificar se possui cheque custodiado
                               no dia de hoje. 
                               PRJ300- Desconto de cheque. (Odirlei-AMcom)
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


	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrborder"]) || !isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrborder = (isset($_POST["nrborder"])) ? $_POST["nrborder"] : 0;
    $flresghj = (isset($_POST["flresghj"])) ? $_POST["flresghj"] : 0;

	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lida.");
	}
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("N&uacute;mero da conta inv&aacute;lida.");
	}

	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
    $xml .= "   <flresghj>".$flresghj."</flresghj>";
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

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>
