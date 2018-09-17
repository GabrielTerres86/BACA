<?
/*!
 * FONTE        : form_atribuicao_detalhamento.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 25/03/2013 
 * OBJETIVO     : Tela de exibição atribuições detalhamento 
 * --------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso novo campo convenio (Daniel).
 *
 *				  11/07/2017 - Inclusao das novas colunas e campos "Tipo de tarifacao", "Percentual", "Valor Minimo" e 
 *                             "Valor Maximo" (Mateus - MoutS)
 *
 * -------------- 
 */		
?>

<style>
.ui-datepicker-trigger{
	float:left;
	margin-left:6px;
	margin-top:6px;
}
</style> 

<form id="frmAtribuicaoDetalhamento" name="frmAtribuicaoDetalhamento" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>
			<td>
				<label for="cdfvlcop"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdfvlcop" name="cdfvlcop" value="<? echo $cdfvlcop == 0 ? '' : $cdfvlcop ?>" />					
			</td> 
		</tr>			
		<tr>
			<td>
				<label for="cdtarifa"><? echo utf8ToHtml('Tarifa:') ?></label>
				<input type="text" id="cdtarifa" name="cdtarifa" value="<? echo $cdtarifa == 0 ? '' : $cdtarifa ?>" />	
				<input type="text" name="dstarifa" id="dstarifa"  value="<? echo utf8ToHtml($dstarifa); ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="vlinifvl"><? echo utf8ToHtml('Faixa de valor:') ?></label>
				<input type="text" id="vlinifvl2" name="vlinifvl2" value="<? echo $vlinifvl2 == '' ? 0 : $vlinifvl2 ?>" />	
				<label for="vlfinfvl"><? echo utf8ToHtml(' a ') ?></label>
				<input type="text" id="vlfinfvl2" name="vlfinfvl2" value="<? echo $vlfinfvl2 == 0 ? '' : $vlfinfvl2 ?>" />	
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdcopaux"><? echo utf8ToHtml('Cooperativa:') ?></label>
				<? if  ( $glbvars["cdcooper"] == 3 ) { ?>
					<input type="text" id="cdcopaux" name="cdcopaux" value="<? echo $cdcooper == 0 ? '' : $cdcooper ?>" />	
				<? } ?>
				<? if  ( $glbvars["cdcooper"] <> 3 ) { ?>
					<input type="text" id="cdcopaux" name="cdcopaux" value="<? echo $glbvars["cdcooper"] ?>" />	
				<? } ?>
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(8);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="nmrescop" id="nmrescop"  value="<? echo $nmrescop; ?>" />
			</td> 
		</tr>
		<tr>
			<td>
				<label for="flgtiptar"><? echo utf8ToHtml('Tipo de Tarifa&ccedil;&atilde;o:') ?></label>
				<input type="radio" name="flgtiptar" id="flgPerc" class="radio" onclick="controlarTipoTarifa();" value="2" <? echo $tpcobtar == '2' ?  'checked' : '' ?>>
				<label for="flgPerc" class="radio"><? echo utf8ToHtml('Percentual') ?></label>
				<input type="radio" name="flgtiptar" id="flgFixo" class="radio" onclick="controlarTipoTarifa();" value="1" <? echo $tpcobtar == '1' ? 'checked' : '' ?>>
				<label for="flgFixo" class="radio"><? echo utf8ToHtml('Valor Fixo') ?></label>
			</td>
		</tr>
		<tr>
			<td>
				<label for="dtdivulg"><? echo utf8ToHtml('Data de divulga&ccedil;&atilde;o:') ?></label>
				<input type="text" id="dtdivulg" name="dtdivulg" value="<? echo $dtdivulg == 0 ? '' : $dtdivulg ?>" />	
				<label for="dtvigenc"><? echo utf8ToHtml('Data inicio vig&ecirc;ncia:') ?></label>
				<input type="text" name="dtvigenc" id="dtvigenc"  value="<? echo $dtvigenc; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="vltarifa2" style="<? echo $cddopfco == 'A' && $tpcobtar == 1 ? '' : 'display: none' ?>"><? echo utf8ToHtml('Valor tarifa:') ?></label>
				<input type="text" id="vltarifa2" name="vltarifa2" value="<? echo $vltarifa == '' ? 0 : $vltarifa ?>" style="<? echo $cddopfco == 'A' && $tpcobtar == 1 ? '' : 'display: none' ?>" />
                <label for="vlperc" style="<? echo $cddopfco == 'A' && $tpcobtar == 2 ? '' : 'display: none' ?>"><? echo utf8ToHtml('Percentual:') ?></label>
				<input type="text" id="vlperc" name="vlperc" value="<? echo $vlpertar == '' ? 0 : $vlpertar ?>" style="<? echo $cddopfco == 'A' && $tpcobtar == 2 ? '' : 'display: none' ?>" />
                <label for="vlminimo" style="<? echo $cddopfco == 'A' && $tpcobtar == 2 ? '' : 'display: none' ?>"><? echo utf8ToHtml('Vl.Min:') ?></label>
				<input type="text" id="vlminimo" name="vlminimo" value="<? echo $vlmintar == '' ? 0 : $vlmintar ?>" style="<? echo $cddopfco == 'A' && $tpcobtar == 2 ? '' : 'display: none' ?>" />
                <label for="vlmaximo" style="<? echo $cddopfco == 'A' && $tpcobtar == 2 ? '' : 'display: none' ?>"><? echo utf8ToHtml('Vl.Max:') ?></label>
				<input type="text" id="vlmaximo" name="vlmaximo" value="<? echo $vlmaxtar == '' ? 0 : $vlmaxtar ?>" style="<? echo $cddopfco == 'A' && $tpcobtar == 2 ? '' : 'display: none' ?>" />
				<label for="vlrepass2" style="<? echo $cddopfco == 'A' ? '' : 'display: none' ?>"><? echo utf8ToHtml('Custo/Repasse:') ?></label>
				<input type="text" name="vlrepass2" id="vlrepass2"  value="<? echo $vlrepass == '' ? 0 : $vlrepass ?>" style="<? echo $cddopfco == 'A' ? '' : 'display: none' ?>" />

			</td>
		</tr>
		<tr>
			<td>
				<div id="divConvenio" name="divConvenio" >
					<label for="nrconven"><? echo utf8ToHtml('Conv&ecirc;nio:') ?></label>
					<input type="text" id="nrconven" name="nrconven" value="<? echo $nrconven == 0 ? '' : $nrconven ?>" />	
					<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(9);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
					<input type="text" name="dsconven" id="dsconven"  value="<? echo $dsconven; ?>" />	
				</div>
				<div id="divLinhaCredito" name="divLinhaCredito" >
					<label for="cdlcremp"><? echo utf8ToHtml('Linha de Credito:') ?></label>
					<input type="text" id="cdlcremp" name="cdlcremp" value="<? echo $cdlcremp == 0 ? '0' : $cdlcremp ?>" />	
					<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(10);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
					<input type="text" name="dslcremp" id="dslcremp"  value="<? echo $dslcremp ?>" />	
				</div>
			</td>
		</tr>
	</table>
	<br style="clear:both" />
</form>


<div id="tabAtribuicaoDetalhamento" name="tabAtribuicaoDetalhamento" style="display:none;">	
</div>	

<div id="divBotoesfrmAtrDetalha" style="margin-top:5px; margin-bottom :10px; text-align:center;">
	<br style="clear:both" />
	<a href="#" class="botao" id="btVoltar"    onClick="<? echo 'fechaRotina($(\'#divUsoGenerico\')); exibeRotina($(\'#divRotina\'));'; ?> return false;">Voltar</a>
	<a href="#" class="botao" id="btReplicar"  onClick="<? echo 'btnReblicar();'; ?> return false;">Replicar</a>
	<a href="#" class="botao" id="btSalvar"    onClick="<? echo /*$cdtipcat == 3 ? "btnConfirmarConcluirComLinhaCredito();" : */"controlaOpFco('".$cddopfco."');" ; ?> return false;">Concluir</a>
</div>


<div id="divBotoesfrmAtrDetalha2" style="margin-top:5px; margin-bottom :10px; text-align:center; display:none">
	<br style="clear:both" />
	<a href="#" class="botao" id="btVoltar"    onClick="<? echo 'btnVoltarAtribDet();'; ?> return false;">Voltar</a>	 
	<a href="#" class="botao" id="btSalvar"    onClick="<? echo "controlaOpFco('".$cddopfco."');"; ?> return false;">Concluir</a>
</div>
	
<script>	

	highlightObjFocus( $('#frmAtribuicaoDetalhamento') );
		
	$('#cdcooper','#frmAtribuicaoDetalhamento').focus();
	
	formataTabAtribuicaoDetalhamento();

  // Controla DatePicker 	
  $.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );	
  
  $(function() {
	  $( "#dtdivulg" ).datepicker({
	  showOn: "button",
	//  maxDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });
  
  $(function() {
	  $( "#dtvigenc" ).datepicker({
	  showOn: "button",
	//  maxDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });

</script>
	
