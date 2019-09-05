<?php
/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 24/01/2019
 * OBJETIVO     : Rotina para controlar as operações da tela PARRAT
 * --------------
 * ALTERAÇÕES   : 08/02/2019 - Adicionado o filtro Cooperativa na consulta e alteração
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
                  25/02/2019 - Adicionado o campo "Habilitar contingência"
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
                  04/03/2019 - Adicionado o campo "Habilitar sugestão" para as cooperativas
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
                  14/05/2019 - Retirado o filtro inpessoa da pesquisa a alteração. Vamos sempre atualizar os dois tipos de produtos
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
                  14/08/2019 - Adicionado a opção Modelo Cálculo Rating
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
*/

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe a operação que está sendo realizada
$consultarAcao = (isset($_POST['consultarAcao'])) ? $_POST['consultarAcao'] : '';
$salvarAcao = (isset($_POST['salvarAcao'])) ? $_POST['salvarAcao'] : '';

// Recebe para consulta via POST
// $formPesquisa_cdcooper = isset($_POST['formPesquisa_pr_cdcooper']) ? $_POST['formPesquisa_pr_cdcooper'] : 0;
// $formPesquisa_inpessoa = isset($_POST['formPesquisa_pr_inpessoa']) ? $_POST['formPesquisa_pr_inpessoa'] : 0;
$formPesquisa_tpproduto = isset($_POST['formPesquisa_pr_tpproduto']) ? $_POST['formPesquisa_pr_tpproduto'] : 0;
$formPesquisa_cooperat = isset($_POST['formPesquisa_pr_cooperat']) ? $_POST['formPesquisa_pr_cooperat'] : 0;

// Recebe para alterar via AJAX
$pr_qtdias_niveis_reducao = isset($_POST['ajx_frm_qtdias_niveis_reducao']) ? $_POST['ajx_frm_qtdias_niveis_reducao'] : 0;
$pr_idnivel_risco_permite_reducao = isset($_POST['ajx_frm_idnivel_risco_permite_reducao']) ? $_POST['ajx_frm_idnivel_risco_permite_reducao'] : 0;
$pr_qtdias_atencede_atualizacao = isset($_POST['ajx_frm_qtdias_atencede_atualizacao']) ? $_POST['ajx_frm_qtdias_atencede_atualizacao'] : 0;

$pr_qtmeses_expiracao_nota = isset($_POST['ajx_frm_qtmeses_expiracao_nota']) ? $_POST['ajx_frm_qtmeses_expiracao_nota'] : 0;
$pr_qtdias_atual_autom_baixo = isset($_POST['ajx_frm_qtdias_atual_autom_baixo']) ? $_POST['ajx_frm_qtdias_atual_autom_baixo'] : 0;
$pr_qtdias_atual_autom_medio = isset($_POST['ajx_frm_qtdias_atual_autom_medio']) ? $_POST['ajx_frm_qtdias_atual_autom_medio'] : 0;
$pr_qtdias_atual_autom_alto = isset($_POST['ajx_frm_qtdias_atual_autom_alto']) ? $_POST['ajx_frm_qtdias_atual_autom_alto'] : 0;
$pr_qtdias_atual_manual = isset($_POST['ajx_frm_qtdias_atual_manual']) ? $_POST['ajx_frm_qtdias_atual_manual'] : 0;
$pr_incontingencia = isset($_POST['ajx_frm_incontingencia']) ? $_POST['ajx_frm_incontingencia'] : 0;
$pr_inpermite_alterar = isset($_POST['ajx_frmPARRATHabilitar']) ? $_POST['ajx_frmPARRATHabilitar'] : 0;

if (strlen($consultarAcao)) {
	if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $consultarAcao)) <> '') {
		exibeErroNew($msgError);
	}
} else {
	if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $salvarAcao)) <> '') {
		exibeErroNew($msgError);
	}
}

if ($consultarAcao == 'C' || $consultarAcao == 'A') {
	$xml = "<Root>";
	$xml .= "<Dados>";
	$xml .= "	<inpessoa>1</inpessoa>";
	$xml .= "	<tpproduto>".$formPesquisa_tpproduto."</tpproduto>";
	$xml .= "	<cooperat>".$formPesquisa_cooperat."</cooperat>";
	$xml .= "</Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "PARRAT_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
} 

if ($consultarAcao == 'P') {
	$xml = "<Root>";
	$xml .= "<Dados>";
	$xml .= "	<cooperat>".$formPesquisa_cooperat."</cooperat>";
	$xml .= "</Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
}

/* Habilita Rating */
if ($salvarAcao == 'P') {

	$xml = "<Root>";
	$xml .= "<Dados>";
	$xml .= "	<inpermite_alterar>".$pr_inpermite_alterar."</inpermite_alterar>";
	$xml .= "	<cooperat>".$formPesquisa_cooperat."</cooperat>";
	$xml .= "</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARRAT", "ALTERA_PARAM_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	echo 'showError("inform","Par&acirc;metros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	return;
}
/* Habilita Rating */

/* Birô Rating */
if ($salvarAcao == 'B') {
	$dados = $_POST['dados'];
	if (count($dados)) {
		foreach ($dados as $key => $item) {
			$xml = "<Root>";
			$xml .= "<Dados>";
			$xml .= "   <inbiro_ibratan>".$item['inbiro']."</inbiro_ibratan>";
			$xml .= "   <cooperat>".$item['cdcooper']."</cooperat>";
			$xml .= "</Dados>";
			$xml .= "</Root>";
			
			$xmlResult = mensageria($xml, "TELA_PARRAT", "ALTERAR_BIRO_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);
		}
	}
	echo 'hideMsgAguardo(); showError("inform","Par&acirc;metros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	return;
}
/* Birô Rating */

/* Tipo Modelo Calculo Rating */
if ($salvarAcao == 'M') {
	$dados = $_POST['dados'];
	if (count($dados)) {
		foreach ($dados as $key => $item) {
			$xml = "<Root>";
			$xml .= "<Dados>";
			$xml .= "   <modelo_ibratan>".$item['inmodelo']."</modelo_ibratan>";
			$xml .= "   <cooperat>".$item['cdcooper']."</cooperat>";
			$xml .= "</Dados>";
			$xml .= "</Root>";
			
			$xmlResult = mensageria($xml, "TELA_PARRAT", "ALTERAR_MODELO_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);
		}
	}
	echo 'hideMsgAguardo(); showError("inform","Par&acirc;metros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	return;
}
if ($salvarAcao == 'A') {

	if (is_array($pr_idnivel_risco_permite_reducao) && count($pr_idnivel_risco_permite_reducao)) {
		$pr_idnivel_risco_permite_reducao = implode(',', $pr_idnivel_risco_permite_reducao) . ',';
	} else {
		$pr_idnivel_risco_permite_reducao = ',';
	}

	if (!((int)$pr_qtdias_niveis_reducao > 0)) {
		echo "showError('error', 'Campo deve ser maior que zero', 'Alerta - Aimaro', 'unblockBackground()'); $('#frm_qtdias_niveis_reducao').focus();";
		exit();
	}

	$xml = "<Root>";
	$xml .= "<Dados>";
	$xml .= "	<inpessoa>1</inpessoa>";
	$xml .= "	<tpproduto>".$formPesquisa_tpproduto."</tpproduto>";
	$xml .= "	<qtdias_niveis_reducao>".$pr_qtdias_niveis_reducao."</qtdias_niveis_reducao>";
	$xml .= "	<idnivel_risco_permite_reduc>".$pr_idnivel_risco_permite_reducao."</idnivel_risco_permite_reduc>";
	$xml .= "	<qtdias_atencede_atualizacao>".$pr_qtdias_atencede_atualizacao."</qtdias_atencede_atualizacao>";
	$xml .= "	<qtdias_reaproveitamento>0</qtdias_reaproveitamento>";
	$xml .= "	<qtmeses_expiracao_nota>".$pr_qtmeses_expiracao_nota."</qtmeses_expiracao_nota>";
	$xml .= "	<qtdias_atual_autom_baixo>".$pr_qtdias_atual_autom_baixo."</qtdias_atual_autom_baixo>";
	$xml .= "	<qtdias_atual_autom_medio>".$pr_qtdias_atual_autom_medio."</qtdias_atual_autom_medio>";
	$xml .= "	<qtdias_atual_autom_alto>".$pr_qtdias_atual_autom_alto."</qtdias_atual_autom_alto>";
	$xml .= "	<qtdias_atual_manual>".$pr_qtdias_atual_manual."</qtdias_atual_manual>";
	$xml .= "	<incontingencia>".$pr_incontingencia."</incontingencia>";
	$xml .= "	<cooperat>".$formPesquisa_cooperat."</cooperat>";
	$xml .= "</Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "PARRAT_ALTERAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

}

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

	if ($msgErro == "") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
	}

	$nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
	exibeErroNew($msgErro,$nmdcampo);
	return;
}

$registros = $xmlObj->roottag->tags[0]->tags;
if ($consultarAcao == 'P') {
	foreach ($registros as $r) {
		echo '$("#frm_inpermite_alterar", "#frmPARRATHabilitar").val("' . getByTagName($r->tags, 'pr_inpermite_alterar') . '");'."\n";
	}
}

if ($consultarAcao == 'C' || $consultarAcao == 'A') {
	foreach ($registros as $r) {
		echo '$("#frm_qtdias_niveis_reducao").val("' . getByTagName($r->tags, 'pr_qtdias_niveis_reducao') . '");'."\n";;

		$arrCheckbox = getByTagName($r->tags, 'pr_idnivel_risco_permite_reduc');

		if (strlen($arrCheckbox)) {
			$itens = explode(',', $arrCheckbox);
			if (count($itens)) {
				foreach ($itens as $key => $value) {
					if (strlen(trim($value))) {
						echo 'selecionaCheckboxPorClasse(".idnivel_risco_permite_reducao", "'.$value.'");'."\n";
					}
				}
			}
		}

		echo '$("#frm_qtdias_atencede_atualizacao").val("' . getByTagName($r->tags, 'pr_qtdias_atencede_atualizacao') . '");'."\n";
		echo '$("#frm_qtmeses_expiracao_nota").val("' . getByTagName($r->tags, 'pr_qtmeses_expiracao_nota') . '");'."\n";
		echo '$("#frm_qtdias_atual_autom_baixo").val("' . getByTagName($r->tags, 'pr_qtdias_atual_autom_baixo') . '");'."\n";
		echo '$("#frm_qtdias_atual_autom_medio").val("' . getByTagName($r->tags, 'pr_qtdias_atual_autom_medio') . '");'."\n";
		echo '$("#frm_qtdias_atual_autom_alto").val("' . getByTagName($r->tags, 'pr_qtdias_atual_autom_alto') . '");'."\n";
		echo '$("#frm_qtdias_atual_manual").val("' . getByTagName($r->tags, 'pr_qtdias_atual_manual') . '");'."\n";
		echo '$("#frm_incontingencia").val("' . getByTagName($r->tags, 'pr_incontingencia') . '");'."\n";
	}
	return;
}

if ($salvarAcao == 'A' || $salvarAcao == 'P') {
	echo 'showError("inform","Par&acirc;metros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
}

function exibeErroNew($msgErro, $nmdcampo) {
	echo 'hideMsgAguardo();';

	if ($nmdcampo <> ""){
		$nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmPARRAT\').focus();';
	}

	$msgErro = str_replace('"', '', $msgErro);
	$msgErro = preg_replace('/\s/',' ',$msgErro);

	echo 'showError("error","' .htmlentities($msgErro). '","Alerta - Ayllos", "'.$nmdcampo.'");';
	exit();
}
