<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 24/03/2016 
 * OBJETIVO     : Rotina para controlar as operações da tela PAREST
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

$tlcooper = (isset($_POST['tlcooper'])) ? $_POST['tlcooper'] : 0;
$contigen = (isset($_POST['contigen'])) ? $_POST['contigen'] : 0;
$incomite = (isset($_POST['incomite'])) ? $_POST['incomite'] : 0;

$cdopcao  = '';

if ( $cddopcao == 'X' ) {
	$cdopcao = 'C';
} else {
	$cdopcao = $cddopcao;
}

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cdopcao)) <> '') {		
	exibeErroNew($msgError);
}

if ( $cdopcao == 'C') {

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tlcooper>" . $tlcooper . "</tlcooper>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PAREST", "PAREST_CONS_PARAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

} else {
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tlcooper>" . $tlcooper . "</tlcooper>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= "   <incomite>" . $incomite . "</incomite>";
	$xml .= "   <contigen>" . $contigen . "</contigen>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PAREST", "PAREST_ALTERA_PARAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
}

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibeErroNew($msgErro);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;
$qtregist = $xmlObj->roottag->tags[1]->cdata;

if ( $cddopcao == 'C') {
	include('tab_resultado.php');
} else {
	if ( $cddopcao == 'X') {
		
		foreach ($registros as $r) {
			
			if ( getByTagName($r->tags, 'contigen') == 'SIM' ) {
				echo '$("#contigen", "#divAlteracao").val("1");';
			} else {
				echo '$("#contigen", "#divAlteracao").val("0");';
			}
			
			if ( getByTagName($r->tags, 'incomite') == 'SIM' ) {
				echo '$("#incomite", "#divAlteracao").val("1");';
			} else {
				echo '$("#incomite", "#divAlteracao").val("0");';
			}
		//	echo '$("#incomite", "#divAlteracao").val("'. getByTagName($r->tags, 'incomite') .'");';
		}
		echo '$("#divBotoes").css({ "display": "block" });';
		echo '$("#divAlteracao").css({ "display": "block" });';
		echo '$("#contigen", "#divAlteracao").focus();';
		echo '$("#btContinuar", "#divBotoes").show();';
		echo 'hideMsgAguardo();';
	} else {
		echo 'showError("inform","Parametro alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
}

function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
