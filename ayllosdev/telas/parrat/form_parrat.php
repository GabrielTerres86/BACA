<?php
/* 
 * FONTE        : form_parrat.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 24/01/2019
 * OBJETIVO     : Formulário de exibição da tela PARRAT
 * ALTERAÇÕES   : 25/02/2019 - Adicionado o campo "Habilitar contingência"
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                04/03/2019 - Adicionado o campo "Habilitar sugestão" para as cooperativas
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                14/05/2019 - Retirado o filtro inpessoa da pesquisa a alteração. Vamos sempre atualizar os dois tipos de produtos
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                06/06/2019 - Adicionado o parâmetro Birô por cooperativa.
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                14/08/2019 - Adicionado a opção Modelo Cálculo Rating
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 */

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

// Carrega permissões do operador
include("../../includes/carrega_permissoes.php");

$cddopcao = $_POST['cddopcao'];

?>
<style>
.col_checkbox {
	height: 75px;
	position: relative;
	display : table; 
	padding: 0px 0px 0px 5px;
}

.row_checkbox {
	float: left;
	width: 80px;
}

.row_risco {
	display : table;
}

.col_risco {
	position: relative;
	display : table;
	padding: 0px;
}

label > input[type="checkbox"] {
	margin: 5px 5px 0px 0px;

}
</style>

<?
if ($cddopcao == 'P') {
?>
<form name="frmPARRATHabilitar" id="frmPARRATHabilitar" class="formulario" style="display:none;">
	<br style="clear:both" />

	<fieldset>
		<legend><? echo utf8_decode('Parâmetros do Rating por Cooperativa') ?></legend>
		<label for="frm_inpermite_alterar" class='labelPri'><? echo utf8_decode('Habilitar alteração:') ?></label>
		<select id="frm_inpermite_alterar" name="frm_inpermite_alterar">
			<option value="1"><? echo utf8_decode(' Sim') ?></option> 
			<option value="0"><? echo utf8_decode(' Não') ?></option>
		</select>
		<br style="clear:both" />
	</fieldset>

</form>

<?
}

if ($cddopcao == 'B') {
	// Retorna valores do tipo de Birô

	$arr_cooper = array();
	$arr_inbiro = array();

	$xmlResult = mensageria("<Root></Root>", "TELA_PARRAT", "CONSULTA_PARAM_BIRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	$xml_cooper = $xmlObj->roottag->tags[0]->tags;
	foreach ($xml_cooper as $r) {
		$arr_cooper[] = array(
			'cdcooper' 	=> getByTagName($r->tags, 'cdcooper'),
			'nmrescop' 	=> getByTagName($r->tags, 'nmrescop'),
			'inbiro' 	=> getByTagName($r->tags, 'inbiro')
		);
	}
	unset($xml_cooper);

	$xml_inbiro = buscaDominios('GEN', 'INBIRO_IBRATAN');
	foreach ($xml_inbiro as $r) {
		$id   = getByTagName($r->tags, 'CDDOMINIO');
		$desc = getByTagName($r->tags, 'DSCODIGO');
		$arr_inbiro[] = array('id' => $id, 'desc' => $desc);
	}
	unset($xml_inbiro);
?>
<form name="frmBIRO" id="frmBIRO" class="formulario">
	<br style="clear:both" />

	<fieldset>
		<legend><? echo utf8_decode('Birô do Rating') ?></legend>

 <?
	if (count($arr_cooper)) {
		echo '<table width="100%"><tbody>';
		$estilo = 'corImpar';

		foreach ($arr_cooper as $key => $item) {
			if ($estilo == 'corPar') {
				$estilo = 'corImpar';
			} else {
				$estilo = 'corPar';
			}

			echo '<tr class="even '.$estilo.'">';
			echo '<td align="right">'.utf8_decode($item['nmrescop']).': </td>';
			echo '<td><select name="frm_inbiro" data-cdcooper="'.$item['cdcooper'].'" class="campo_inbiro">';
			foreach ($arr_inbiro as $keyinbiro => $inbiroitem) {
				$selected = '';
				if ($item['inbiro'] == $inbiroitem['id']) {
					$selected = ' selected';
				}
				echo '<option value="'.$inbiroitem['id'].'" '.$selected.'>'.$inbiroitem['desc'].'</option>';
			}
			echo '</select></td>';
			echo '</tr>'."\n";
		}
		echo '</tbody></table>';
	}
?>
	</fieldset>

</form>
<?
}

if ($cddopcao == 'M') {
	// Retorna valores do calculo do rating

	$arr_cooper = array();
	$arr_inmodelo = array();

	$xmlResult = mensageria("<Root></Root>", "TELA_PARRAT", "CONSULTA_PARAM_MODELO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	$xml_cooper = $xmlObj->roottag->tags[0]->tags;
	foreach ($xml_cooper as $r) {
		$arr_cooper[] = array(
			'cdcooper' => getByTagName($r->tags, 'cdcooper'),
			'nmrescop' => getByTagName($r->tags, 'nmrescop'),
			'inmodelo' => getByTagName($r->tags, 'inmodelo')
		);
	}
	unset($xml_cooper);

	$xml_inmodelo = buscaDominios('GEN', 'INMODELO_IBRATAN');
	foreach ($xml_inmodelo as $r) {
		$id   = getByTagName($r->tags, 'CDDOMINIO');
		$desc = getByTagName($r->tags, 'DSCODIGO');
		$arr_inmodelo[] = array('id' => $id, 'desc' => $desc);
	}
	unset($xml_inmodelo);
?>
<form name="frmMODELO" id="frmMODELO" class="formulario">
	<br style="clear:both" />

	<fieldset>
		<legend><? echo utf8_decode('Modelo do Cálculo') ?></legend>

 <?
	if (count($arr_cooper)) {
		echo '<table width="100%"><tbody>';
		$estilo = 'corImpar';

		foreach ($arr_cooper as $key => $item) {
			if ($estilo == 'corPar') {
				$estilo = 'corImpar';
			} else {
				$estilo = 'corPar';
			}

			echo '<tr class="even '.$estilo.'">';
			echo '<td align="right">'.utf8_decode($item['nmrescop']).': </td>';
			echo '<td><select name="frm_inmodelo" data-cdcooper="'.$item['cdcooper'].'" class="campo_inmodelo">';
			foreach ($arr_inmodelo as $keyinmodelo => $inmodeloitem) {
				$selected = '';
				if ($item['inmodelo'] == $inmodeloitem['id']) {
					$selected = ' selected';
				}
				echo '<option value="'.$inmodeloitem['id'].'" '.$selected.'>'.$inmodeloitem['desc'].'</option>';
			}
			echo '</select></td>';
			echo '</tr>'."\n";
		}
		echo '</tbody></table>';
	}
?>
	</fieldset>

</form>
<?
}

if ($cddopcao == 'C' || $cddopcao == 'A') {
?>

<form name="frmPARRAT" id="frmPARRAT" class="formulario" style="display:none;">
	<br style="clear:both" />

	<fieldset>
		<legend><? echo utf8_decode('Parâmetros do Rating') ?></legend>

		<label for="frm_qtdias_niveis_reducao" class='labelPri'><? echo utf8_decode('Quantidade de níveis de Rating para Melhora/Redução:') ?></label>
		<input title="" type="text" id="frm_qtdias_niveis_reducao" name="frm_qtdias_niveis_reducao" class="inteiro" value="<?php echo $pr_qtdias_niveis_reducao == 0 ? '' : $pr_qtdias_niveis_reducao ?>" maxlength="6" style="text-align:right;"/>
		<label>&nbsp;</label>
		<br style="clear:both" />

		<label class='labelPri labelidnivel'><? echo utf8_decode('Permite melhorar os Níveis de Risco:') ?></label>
		<div class="col_checkbox">
			<div class="row_checkbox">
				<label class="container">AA
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="AA">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">A
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="A">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">B
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="B">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">C
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="C">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">D
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="D">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">E
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="E">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">F
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="F">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">G
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="G">
				</label>
			</div>
			<div class="row_checkbox">
				<label class="container">H
					<input type="checkbox" name="frm_idnivel_risco_permite_reducao[]" class="idnivel_risco_permite_reducao" value="H">
				</label>
			</div>
		</div>
		<br style="clear:both" />

		<label for="frm_qtdias_atencede_atualizacao" class='labelPri'><? echo utf8_decode('Prazo de antecedência para atualizar Rating:') ?></label>
		<input title="" type="text" id="frm_qtdias_atencede_atualizacao" name="frm_qtdias_atencede_atualizacao" class="inteiro" value="<?php echo $pr_qtdias_atencede_atualizacao == 0 ? '' : $pr_qtdias_atencede_atualizacao ?>" maxlength="6" style="text-align:right;"/><label>&nbsp;dias</label>
		<br style="clear:both" />

		<label for="frm_qtmeses_expiracao_nota" class='labelPri'><? echo utf8_decode('Prazo de Expiração do Rating:') ?></label>
		<input title="" type="text" id="frm_qtmeses_expiracao_nota" name="frm_qtmeses_expiracao_nota" class="inteiro" value="<?php echo $pr_qtmeses_expiracao_nota == 0 ? '' : $pr_qtmeses_expiracao_nota?>" maxlength="6" style="text-align:right;"/><label>&nbsp;dias</label>
		<br style="clear:both" />

		<label class='labelPri'><? echo utf8_decode('Prazo atualização automática Rating conforme Risco:') ?></label>
		<div class="col_risco">
			<div class="row_risco">
			<label for="frm_qtdias_atual_autom_baixo" class='labelPri' style="font-weight: normal;"><? echo utf8_decode('Baixo risco:') ?></label>
			<input title="" type="text" id="frm_qtdias_atual_autom_baixo" name="frm_qtdias_atual_autom_baixo" class="inteiro" value="<?php echo $pr_qtmeses_expiracao_nota == 0 ? '' : $pr_qtdias_atual_autom_baixo?>" maxlength="6" style="text-align:right;"/><label>&nbsp;dias</label>
			</div>
			<div class="row_risco">
				<label for="frm_qtdias_atual_autom_medio" class='labelPri' style="font-weight: normal;"><? echo utf8_decode('Médio risco:') ?></label>
				<input title="" type="text" id="frm_qtdias_atual_autom_medio" name="frm_qtdias_atual_autom_medio" class="inteiro" value="<?php echo $pr_qtmeses_expiracao_nota == 0 ? '' : $pr_qtdias_atual_autom_medio?>" maxlength="6" style="text-align:right;"/><label>&nbsp;dias</label>
			</div>
			<div class="row_risco">
				<label for="frm_qtdias_atual_autom_alto" class='labelPri' style="font-weight: normal;"><? echo utf8_decode('Alto risco:') ?></label>
				<input title="" type="text" id="frm_qtdias_atual_autom_alto" name="frm_qtdias_atual_autom_alto" class="inteiro" value="<?php echo $pr_qtdias_atual_autom_alto == 0 ? '' : $pr_qtdias_atual_autom_alto?>" maxlength="6" style="text-align:right;"/><label>&nbsp;dias</label>
			</div>
		</div>
		<br style="clear:both" />

		<label for="frm_qtdias_atual_manual" class='labelPri'><? echo utf8_decode('Prazo de atualização manual:') ?></label>
		<input title="" type="text" id="frm_qtdias_atual_manual" name="frm_qtdias_atual_manual" class="inteiro" value="<?php echo $pr_qtdias_atual_manual == 0 ? '' : $pr_qtdias_atual_manual?>" maxlength="6" style="text-align:right;"/><label>&nbsp;dias</label>
		<br style="clear:both" />

		<label for="frm_incontingencia" class='labelPri'><? echo utf8_decode('Habilitar contingência:') ?></label>
		<select id="frm_incontingencia" name="frm_incontingencia">
			<option value="1"><? echo utf8_decode(' Sim') ?></option> 
			<option value="0"><? echo utf8_decode(' Não') ?></option>
		</select>
		<br style="clear:both" />

	</fieldset>

</form>
<?
}
?>

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onclick="estadoInicial(); return false;">Voltar</a>
	<a href="#" class="botao" id="btContinuar"  onClick="parrat_alterar(); return false;">Alterar</a>
</div>
