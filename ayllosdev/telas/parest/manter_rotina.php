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
$nmregmot = (isset($_POST['nmregmot'])) ? $_POST['nmregmot'] : '';
$qtsstime = (isset($_POST['qtsstime'])) ? $_POST['qtsstime'] : 0;
$qtmeschq = (isset($_POST['qtmeschq'])) ? $_POST['qtmeschq'] : 0;
$qtmesest = (isset($_POST['qtmesest'])) ? $_POST['qtmesest'] : 0;
$qtmesemp = (isset($_POST['qtmesemp'])) ? $_POST['qtmesemp'] : 0;

$cdopcao  = '';

if ( $cddopcao == 'X' ) {
	$cdopcao = 'C';
} else {
	$cdopcao = $cddopcao;
}

if ($cdopcao == 'A'){
	if ((!isset($_POST['nmregmot'])) || $_POST['nmregmot'] == ''){
		echo 'hideMsgAguardo();';
		echo 'showError("error","Regra An&aacute;lise Autom&aacute;tica &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#nmregmot\', \'#frmParest\').focus()");';
		exit();
	}

	if ((!isset($_POST['qtsstime'])) || $_POST['qtsstime'] == ''){
		echo 'hideMsgAguardo();';
		echo 'showError("error","Timeout An&aacute;lise Autom&aacute;tica &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#qtsstime\', \'#frmParest\').focus()");';
		exit();
	}
	
	if ((!isset($_POST['qtmeschq'])) || $_POST['qtmeschq'] == ''){
		echo 'hideMsgAguardo();';
		echo 'showError("error","Qtde de meses para Dev. Cheques &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#qtmeschq\', \'#frmParest\').focus()");';
		exit();
	}
	if ((!isset($_POST['qtmesest'])) || $_POST['qtmesest'] == ''){
		echo 'hideMsgAguardo();';
		echo 'showError("error","Qtde de meses para Estouros &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#qtmesest\', \'#frmParest\').focus()");';
		exit();
	}
	if ((!isset($_POST['qtmesemp'])) || $_POST['qtmesemp'] == ''){
		echo 'hideMsgAguardo();';
		echo 'showError("error","Qtde de meses para Atraso de Empr&eacute;stimos &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#qtmesemp\', \'#frmParest\').focus()");';
		exit();
	}

	if (preg_match('/[^a-zA-Z0-9_]/',$nmregmot) == 1){
		echo 'hideMsgAguardo();';
		echo 'showError("error","Informe somente letras, n&uacute;meros e \'_\' neste campo! O preenchimento de \"Espa&ccedil;os\" n&atilde;o &eacute; permitido!","Alerta - Ayllos","$(\'#nmregmot\', \'#frmParest\').focus()");';
		exit();
	}
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
	$xml .= "   <nmregmot>" . $nmregmot . "</nmregmot>";
	$xml .= "   <qtsstime>" . $qtsstime . "</qtsstime>";
	$xml .= "   <qtmeschq>" . $qtmeschq . "</qtmeschq>";
	$xml .= "   <qtmesest>" . $qtmesest . "</qtmesest>";
	$xml .= "   <qtmesemp>" . $qtmesemp . "</qtmesemp>";
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
			echo '$("#nmregmot", "#divAlteracao").val("'.getByTagName($r->tags, 'nmregmot').'");';
			echo '$("#qtsstime", "#divAlteracao").val("'.getByTagName($r->tags, 'qtsstime').'");';
			echo '$("#qtmeschq", "#divAlteracao").val("'.getByTagName($r->tags, 'qtmeschq').'");';
			echo '$("#qtmesest", "#divAlteracao").val("'.getByTagName($r->tags, 'qtmesest').'");';
			echo '$("#qtmesemp", "#divAlteracao").val("'.getByTagName($r->tags, 'qtmesemp').'");';
			
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
