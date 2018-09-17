<?
/*!
 * FONTE        : form_detalhes_faixa.php
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 03/12/2015
 * OBJETIVO     : Tela de exibição detalhamento de faixas de IRRF
 * --------------
 * ALTERAÇÕES   :
 */		
?>

<script>

$(document).ready(function() {
	
	if (cddopdet == 'I') {
		$('#cdfaixa','#frmDetalhaFaixa').val('');
		$('#cdfaixa','#frmDetalhaFaixa').desabilitaCampo();
		$('#vlfaixa_inicial','#frmDetalhaFaixa').val( '0,00' );
		$('#vlfaixa_final','#frmDetalhaFaixa').val( '999.999.999,00' );
		$('#vlpercentual_irrf','#frmDetalhaFaixa').val( '0,00' );
		$('#vldeducao','#frmDetalhaFaixa').val( '0,00' );
	}
	
	// A - Alteração 		X - Consulta Cooperativa
	if ( (cddopdet == 'A') || (cddopdet == 'X') ) {
		
		var vlfaixa_inicial = ( glbTabVlfaixa_inicial ) ;
			vlfaixa_inicial = number_format(vlfaixa_inicial,2,',','');
		
		var vlfaixa_final = ( glbTabVlfaixa_final ) ;
			vlfaixa_final = number_format(vlfaixa_final,2,',','');
		
		var vlpercentual_irrf = ( glbTabVlpercentual_irrf ) ;
			vlpercentual_irrf = number_format(vlpercentual_irrf,2,',','');
		
		var vldeducao = ( glbTabVldeducao ) ;
			vldeducao = number_format(vldeducao,2,',','');
		
		$('#cdfaixa','#frmDetalhaFaixa').desabilitaCampo();
		$('#cdfaixa','#frmDetalhaFaixa').val(glbTabCdfaixa);
		
		$('#vlfaixa_inicial','#frmDetalhaFaixa').val(vlfaixa_inicial);
		$('#vlfaixa_final','#frmDetalhaFaixa').val(vlfaixa_final);
		$('#vlpercentual_irrf','#frmDetalhaFaixa').val(vlpercentual_irrf);
		$('#vldeducao','#frmDetalhaFaixa').val(vldeducao);
		
		aux_cdfaixa = glbTabCdfaixa;
	}	
	
	return false;	
});

</script>
<form id="frmDetalhaFaixa" name="frmDetalhaFaixa" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>		
			<td>
				<label for="cdfaixa"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdfaixa" name="cdfaixa" />
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Limites de valor da Faixa</legend>	
					<label for="vlfaixa_inicial"><? echo utf8ToHtml('Inicial:') ?></label>
					<input type="text" id="vlfaixa_inicial" name="vlfaixa_inicial"  />	
					<br style="clear:both" />
					<label for="vlfaixa_final"><? echo utf8ToHtml('Final:') ?></label>
					<input type="text" id="vlfaixa_final" name="vlfaixa_final"  />	
				</fieldset>
			</td>
		</tr>
		<tr>
			<td>
				<label for="vlpercentual_irrf"><? echo utf8ToHtml('Percentual:') ?></label>
				<input type="text" id="vlpercentual_irrf" name="vlpercentual_irrf"  />	
			</td>
		</tr>
		<tr>
			<td>
				<label for="vldeducao"><? echo utf8ToHtml('Valor de Dedução:') ?></label>
				<input type="text" id="vldeducao" name="vldeducao"  />	
			</td>
		</tr>
	</table>
</form>

<div id="divTabDetalhamento" name="divTabDetalhamento" style="display:none">	
		
</div>

<div id="divBotoesfrmDetalhaFaixa" style="margin-bottom: 5px; text-align:center;" >
	<a href="#" class="botao" id="btVoltar"  	onClick="<? echo 'fechaRotina($(\'#divRotina\')); carregaDetalhamento();'; ?> return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar"  	onClick="<? echo 'fechaRotina($(\'#divRotina\')); carregaDetalhamento();'; ?> return false;">Concluir</a>
	<a href="#" class="botao" id="btContinuar"  onClick="realizaOpDetalhamento(cddopdet);">Concluir</a>
</div>

<script>
	$("#btSalvar","#divBotoesfrmDetalhaFaixa").hide();
	highlightObjFocus( $('#frmDetalhaFaixa') );
	$('#vlfaixa_inicial','#frmDetalhaFaixa').focus();
	controlafrmDetalhaFaixa();
</script>
	