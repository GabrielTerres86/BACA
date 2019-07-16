<?php
/* !
 * FONTE        : tabela_historico_gravame.php
 * CRIAÇÃO      : Christian Grauppe - Envolti
 * DATA CRIAÇÃO : 10/04/2019
 * OBJETIVO     : Tabela que apresenta os detalhes dos investimentos
 *
 */
 function formataNumero($number,$type="BR") {
	if ($type == "BR") {
		$number = str_replace(',', '', $number);
		return number_format($number, 2, ',', '.');
	} elseif ($type == "-") {
		$number = str_replace(',', '.', $number);
		//$number = number_format($number, 2, '.', '');
		return (int)str_replace('.', '', $number);
	} elseif ($type == "BD-EN") { //envio para banco 1000,00
		$number = str_replace(',', '', $number);
		return number_format($number, 2, ',', '');
	} elseif ($type == "BD-BR") { //envio para banco 1000,00
		return number_format($number, 2, ',', '');
	} else {
		$number = str_replace(',', '', $number);
		return number_format($number, 2, '.', '');
	}
 }
?>
<style>
	td.acao {
		margin: 0 auto;
	}
	td.acao a {
		margin: 5px 2px;
		display: block;
		float: left;
	}
	input.vlrtaxmens, input.vlradic {
		width:100px;
	}
	.divRegistros table tfoot tr td {
		font-size: 12px;
		height: 22px;
		padding: 0px 5px;
		border-right: 1px dotted #999;
		background-color: #f7d3ce;
		cursor: default;
	}
</style>
<form name="formInvest" id="frmTabInvest" method="post">
	<div id="divTabelaInvest">
		<div class="divRegistros">
			<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
			<input type="hidden" name="redirect" id="redirect" value="html_ajax" />
			<table>
				<thead>
					<tr>
						<th>De</th>
						<th><? echo utf8ToHtml('Até'); ?></th>
						<th><? echo utf8ToHtml('Taxa Mensal (%)'); ?></th>
						<th><? echo utf8ToHtml('Adicional (R$)'); ?></th>
						<th><? echo utf8ToHtml('Ações'); ?></th>
					</tr>
				</thead>
				<tbody>
					<?php
					//$vlrAnt = 0;
					for ($i = 0; $i < $qtregist; $i++) {
						$acima = ($i == $qtregist-1) ? 'Acima de ' : '';
						if ($acima) {
							$vlfaixate = 0;
						} else {
							$vlfaixate = getByTagName($detalhesInv[$i]->tags, 'vlfaixate');
						}
						$vlrAnt = getByTagName($detalhesInv[$i]->tags, 'vlfaixde');
						$vladicio = getByTagName($detalhesInv[$i]->tags, 'vladicio');
						$pctaxmen = getByTagName($detalhesInv[$i]->tags, 'pctaxmen');
						?>
						<tr>
							<td class="vlrde" data-vlr="<?php echo formataNumero($vlrAnt,"EN"); ?>"><span><?php echo formataNumero(formataNumero($vlrAnt,"EN"),"-"); ?></span><?php echo $acima.formataNumero($vlrAnt); ?></td>
							<td class="vlrate" data-vlr="<?php echo formataNumero($vlfaixate,"EN"); ?>"><span><?php echo formataNumero(formataNumero($vlfaixate),"-"); ?></span><?php echo ($acima) ? '' : formataNumero($vlfaixate); ?></td>
							<td class="vlrtaxmens"><span><?php echo $pctaxmen; ?></span><input name="pctaxmen[]" type="text" value="<?php echo str_replace('.', ',', $pctaxmen); ?>" class='campo vlrtaxmens' maxlength="25" /></td>
							<td class="vlradicional"><span><?php echo formataNumero($vladicio,"-"); ?></span><input name="vladicio[]" type="text" value="<?php echo formataNumero($vladicio); ?>" class='campo vlradic' maxlength="25" /></td>
							<td class="acao infos">
								<input name="idfrninv[]" value="<?php echo getByTagName($detalhesInv[$i]->tags, 'idfrninv'); ?>" type="hidden" />
								<input name="vlfaixde[]" value="<?php echo formataNumero($vlrAnt,"BD-EN"); ?>" type="hidden" />
								<input name="vlfaixate[]" value="<?php echo formataNumero($vlfaixate,"BD-EN"); ?>" type="hidden" />
								<?php /*
								<input name="pctaxmen[]" value="<?php echo str_replace('.', ',', $pctaxmen); ?>" type="hidden" />
								<input name="vladicio[]" value="<?php echo formataNumero($vladicio,"BD-BR"); ?>" type="hidden" />
								*/ ?>
								<a class="btnDelLinha" title="Excluir linha atual" href="#"><img src="<? echo $UrlImagens; ?>geral/servico_nao_ativo.gif" height="20px" /></a>
							</td>
						</tr>
					<?php
						//$vlrAnt = getByTagName($detalhesInv[$i]->tags, 'vlfaixate');
						} ?>
				</tbody>
				<tfoot>
					<tr id="linObsClick_ad AddLinha">
						<td class="vlrde"><input name="vlrde" type="text" value="" class='campo vlrde' data-name="vlfaixde" maxlength="25" /></td>
						<td class="vlrate"><input name="vlrate" type="text" value="" class='campo vlrate' data-name="vlfaixate" maxlength="25" /></td>
						<td class="vlrtaxmens"><input name="vlrtaxmens" type="text" value="" class='campo vlrtaxmens' data-name="pctaxmen" maxlength="25" /></td>
						<td class="vlradicional"><input name="vlradicional" type="text" value="" class='campo vlradic' data-name="vladicio" maxlength="25" /></td>
						<td class="acao infos">
							<a class="btnAddLinha" title="Incluir linha" href="#" onClick="return false;"><img src="<? echo $UrlImagens; ?>geral/servico_ativo.gif" height="20px" /></a>
							<a class="btnDelLinha" title="Excluir linha atual" href="#" style="display:none;"><img src="<? echo $UrlImagens; ?>geral/servico_nao_ativo.gif" height="20px" /></a>
						</td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btGravarTabInvest" onClick="btnGravarTabInvest(); return false;">Gravar</a>
</div>

<script>
$(document).ready(function () {
	$('tfoot input.vlrde').maskMoney({thousands:'.', decimal:','});
	$('tfoot input.vlrate').maskMoney({thousands:'.', decimal:','});
	$('input.vlrtaxmens').maskMoney({thousands:'.', decimal:',',precision:8});
	$('input.vlradic').maskMoney({thousands:'.', decimal:','});
});
</script>