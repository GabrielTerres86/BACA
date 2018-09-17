<?
/*!
 * FONTE        : form_detalha_tarifa.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 05/03/2012 
 * OBJETIVO     : Tela de exibição detalhamento de tarifas
 * --------------
 * ALTERAÇÕES   :
 */		
?>

<script>

$(document).ready(function() {

	
	
	var aux_cdfaixav = 0;
	
	$('#cdtarifa','#frmDetalhaTarifa').val( $('#cdtarifa','#frmCab').val() );
	$('#dstarifa','#frmDetalhaTarifa').val( $('#dstarifa','#frmCab').val().toUpperCase() );

	if (cddopdet == 'I') {
		$('#cdfaixav','#frmDetalhaTarifa').desabilitaCampo();
		buscaSequencialDetalhamento();	
		$('#vlinifvl','#frmDetalhaTarifa').val( '0,00' );
		$('#vlfinfvl','#frmDetalhaTarifa').val( '999.999.999,00');
		aux_cdfaixav = $('#cdfaixav','#frmDetalhaTarifa').val();
	}
	
	// A - Alteração 		X - Consulta Cooperativa
	if ( (cddopdet == 'A') || (cddopdet == 'X') ) {
		
		var vlinifvl = ( glbTabVlinifvl ) ;
			vlinifvl = number_format(vlinifvl,2,',','');
			
		var vlfinfvl = ( glbTabVlfinfvl ) ;
			vlfinfvl = number_format(vlfinfvl,2,',','');
						
		
		$('#cdfaixav','#frmDetalhaTarifa').desabilitaCampo();
		$('#cdfaixav','#frmDetalhaTarifa').val(glbTabCdfaixav);
		$('#vlinifvl','#frmDetalhaTarifa').val(vlinifvl);
		$('#vlfinfvl','#frmDetalhaTarifa').val(vlfinfvl);
		$('#cdhistor','#frmDetalhaTarifa').val(glbTabCdhistor);
		$('#cdhisest','#frmDetalhaTarifa').val(glbTabCdhisest);
		$('#dshistor','#frmDetalhaTarifa').val(glbTabDshistor);
		$('#dshisest','#frmDetalhaTarifa').val(glbTabDshisest);
		
		aux_cdfaixav = glbTabCdfaixav;
	}	
	
	return false;	
});

</script>

<form id="frmDetalhaTarifa" name="frmDetalhaTarifa" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cdfaixav"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdfaixav" name="cdfaixav" value="<? echo $cdfaixav == 0 ? '' : $cdfaixav ?>" />	
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdtarifa"><? echo utf8ToHtml('Tarifa:') ?></label>
				<input type="text" id="cdtarifa" name="cdtarifa" value="<? echo $cdtarifa == 0 ? '' : $cdtarifa ?>" />	
				<input type="text" name="dstarifa" id="dstarifa"  value="<? echo $dstarifa; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Limites da faixa de valor</legend>	
					<label for="vlinifvl"><? echo utf8ToHtml('Inicial:') ?></label>
					<input type="text" id="vlinifvl" name="vlinifvl"  />	
					<br style="clear:both" />
					<label for="vlfinfvl"><? echo utf8ToHtml('Final:') ?></label>
					<input type="text" id="vlfinfvl" name="vlfinfvl"  />	
				</fieldset>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdhistor"><? echo utf8ToHtml('Hist&oacute;rico lan&ccedil;amento:') ?></label>
				<input type="text" id="cdhistor" name="cdhistor" value="<? echo $cdhistor == 0 ? '' : $cdhistor ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(4);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dshistor" id="dshistor"  value="<? echo $dshistor; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdhisest"><? echo utf8ToHtml('Hist&oacute;rico estorno:') ?></label>
				<input type="text" id="cdhisest" name="cdhisest" value="<? echo $cdhisest == 0 ? '' : $cdhisest ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(5);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dshisest" id="dshisest"  value="<? echo $dshisest; ?>" />

			</td>
		</tr>
	</table>
</form>

<div id="divTabDetalhamento" name="divTabDetalhamento" style="display:none">	
		
</div>	

<div id="divBotoesfrmDetalhaTarifa" style="margin-bottom: 5px; text-align:center;" >
	<br style="clear:both">
	<a href="#" class="botao" id="btVoltar"  	onClick="<? echo 'fechaRotina($(\'#divRotina\')); carregaDetalhamento();'; ?> return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar"  	onClick="<? echo 'fechaRotina($(\'#divRotina\')); carregaDetalhamento();'; ?> return false;">Concluir</a>
	<a href="#" class="botao" id="btContinuar"  onClick="verificaLancLat(cddopdet);">Prosseguir</a>
</div>
	
	
<script>
	$("#btSalvar","#divBotoesfrmDetalhaTarifa").hide();
	highlightObjFocus( $('#frmDetalhaTarifa') );
	$('#vlinifvl','#frmDetalhaTarifa').focus();
	controlafrmDetalhaTarifa();		
</script>	
	