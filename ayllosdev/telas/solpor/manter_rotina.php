<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/2018
 * OBJETIVO     : Rotina para controlar as operações da tela SOLPOR
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

$cddopcao = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$acao = (!empty($_POST['acao'])) ? $_POST['acao'] : '';
$cdcooper = (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
$nrdconta = (!empty($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$dsrowid = (!empty($_POST['dsrowid'])) ? $_POST['dsrowid'] : '';
$cdmotivo = (!empty($_POST['cdmotivo'])) ? $_POST['cdmotivo'] : '';
$idsituacao = (!empty($_POST['idsituacao'])) ? $_POST['idsituacao'] : '';

function exibeErro($msgErro, $flgfundo) {
	echo 'hideMsgAguardo();';
	if ($flgfundo) {
		echo 'showError("error","'.addslashes($msgErro).'","Alerta - Aimaro","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))");';
	} else {
		echo 'showError("error","'.addslashes($msgErro).'","Alerta - Aimaro","");';
	}
	exit();
}

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErro($msgError, false);
}

if ($acao == 'direcionarPortabilidade') {
	$xml = new XmlMensageria();
	$xml->add('cdcooper',$cdcooper);
	$xml->add('nrdconta',$nrdconta);
	$xml->add('dsrowid',$dsrowid);
	$xmlResult = mensageria($xml, "SOLPOR", "REALIZA_DIRECIONAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
		exibeErro($msgErro, true);
	}

	if (strtoupper($xmlObj->roottag->tags[0]->tags[0]->name) == "RETORNO") {
		if ($xmlObj->roottag->tags[0]->tags[0]->cdata == "1") {
			echo "showError('inform','Portabilidade direcionada com sucesso.','Alerta - Aimaro','fechaRotina($(\'#divUsoGenerico\'));grid.reload();',false);";
		}
	}
} else if ($acao == 'avaliarPortabilidade') {
	$xml = new XmlMensageria();
	$xml->add('dsrowid',$dsrowid);
	$xml->add('cdmotivo',$cdmotivo);
	$xml->add('idsituacao',$idsituacao);
	$xmlResult = mensageria($xml, "SOLPOR", "AVALIA_PORTABILIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
		exibeErro($msgErro, false);
	}

	if (strtoupper($xmlObj->roottag->tags[0]->tags[0]->name) == "RETORNO") {
		if ($xmlObj->roottag->tags[0]->tags[0]->cdata == "1") {
			echo "showError('inform','Portabilidade avaliada com sucesso.','Alerta - Aimaro','fechaRotina($(\'#divUsoGenerico\'));grid.reload();',false);";
		}
	}
} else {
	exibeErro('Ação inválida.', false);
}