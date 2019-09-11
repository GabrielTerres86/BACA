<?
/*!
 * FONTE        : ratmov_justificar.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 08/02/2019
 * OBJETIVO     : Tela de justificar rating
 */

session_start();

require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");

$dadosRating = $_POST['dadosRating'];
?>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
					<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Justificativas Rating') ?></td>
					<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="ratmov_fecharJustificativas($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
					<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="tdConteudoTela" align="center">
			<form id="frmJustificacoes" name="frmJustificacoes" class="formulario justificacoes">

				<div id="ratmovErros" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px; height: 200px; display: none;">
					<a href="#" class="botao" id="btnRATMOV_ErroSalvar" name="btnRATMOV_ErroSalvar" onClick="ratmov_fecharJustificativas(); return false;" style = "margin: 5px 0px 10px 10px; text-align:right;"><?=utf8_decode('Não')?></a>
				</div>

				<div id="ratmovConfirmacaoSalvar" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px; height: 200px; display: none;">
					<label for="" style="padding: 50px 0px 0px 110px;"><?=utf8_decode('Deseja enviar para análise?')?></label>
					<br style="clear:both" />
					<a href="#" class="botao" id="btnRATMOV_SalvarSIM" name="btnRATMOV_SalvarSIM" onClick="return false;" style = "margin: 15px 0px 10px 145px; text-align:right;"><?=utf8_decode('Sim')?></a>
					<a href="#" class="botao" id="btnRATMOV_SalvarNAO" name="btnRATMOV_SalvarNAO" onClick="ratmov_fecharJustificativas(); return false;" style = "margin: 15px 0px 10px 10px; text-align:right;"><?=utf8_decode('Não')?></a>
				</div>

				<div id="ratmovIDJustificativas" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px; height: 200px; overflow-y:scroll;">
<?
if (count($dadosRating)) {

	$total = 0;
	
	// Verifica se tem mais de uma nota que vai para esteira
	$possuiMaisUmaJustificativaEsteira = false;
	foreach ($dadosRating as $key => $value) {
		$item = $value[0];
		if ($item['novanota'] != '') {
			$total++;
		}
	}
	if ($total > 1) {
		$possuiMaisUmaJustificativaEsteira = true;
	}
	// Verifica se tem mais de uma nota que vai para esteira
	
	// Monta Interface
	$total = 0;
	foreach ($dadosRating as $key => $value) {
		$item = $value[0];
		$checkRepetirJustificativa = '
<div style="width:315px; display: block; margin: 0px 5px 0px 25px; padding: 0px; text-align:left; font-size: 10px;">
	<span class="totalJustificativaCaracter" id="contadorJustificativa'.$item['id'].'" style="font-size: 10px; float: right; margin-right: 20px; color: red;">0 caracteres</span>
</div>';


		// Diferente de vazio então vai para esteira
		if ($item['novanota'] != '') {
			if ($total == 0 && $possuiMaisUmaJustificativaEsteira) {
				$checkRepetirJustificativa = '
<div style="width:315px; display: block; margin: 0px 5px 0px 25px; padding: 0px; text-align:left; font-size: 10px;">
	<input style="margin-right:5px" type="checkbox" id="checkboxRepetirJustificativa" onClick="ratmov_repetirJustificativa(\'campoJustificativa'.$item['id'].'\')"> Repetir a justificativa
	<span class="totalJustificativaCaracter" id="contadorJustificativa'.$item['id'].'" style="font-size: 10px; float: right; margin-right: 20px; color: red;">0 caracteres</span>
</div>';
			}
			echo '
<label for="campoJustificativa'.$item['id'].'" style="padding-left: 30px;">Contrato '.mascara($item['contrato'],'#.###.###.###').' nota &quot;'.strtoupper($item['novanota']).'&quot;:</label>
<textarea style="width:296px;height:61px;" class="textarea campoJustificativa" data-idjustificativa="'.$item['id'].'" id="campoJustificativa'.$item['id'].'" name="campoJustificativa'.$item['id'].'" placeholder="'.utf8_decode('Informe uma justificava para a alteração do rating').'"></textarea>
'.$checkRepetirJustificativa.'
<br style="clear:both" />
			';
			$total++;
		}
		// Diferente de vazio então vai para esteira
	}
	// Monta Interface
}
?>
					<div id="ratmovJustificativaValidacao" style="display:none; width: 315px;color: red;border: 1px solid red;padding: 5px;font-size: 11px;"></div>
					
					<a href="#" class="botao" id="btnSalvarJustificativa" name="btnSalvarJustificativa" onClick="return false;" style = "margin: 5px 0px 10px 27px; text-align:right;">Salvar</a>
					<a href="#" class="botao" id="btnCancelarJustificativa" name="btnCancelarJustificativa" onClick="ratmov_fecharJustificativas(); return false;" style = "margin: 5px 0px 10px 10px; text-align:right;">Cancelar</a>
					<br style="clear:both" />
					
					
					
					<div style="width:315px; display: block; margin: 0px 5px 0px 0px; padding: 0px;"></div>
				</div>
			</form>
		</td> 
	</tr>
</table>
