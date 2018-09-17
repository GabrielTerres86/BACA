<?
/*!
 * FONTE        : form_vinculacao_parametro.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 05/03/2012 
 * OBJETIVO     : Tela de exibição form vinculação parâmetro de tarifas
 * --------------
 * ALTERAÇÕES   :
 */		
?>

<script>

$(document).ready(function() {
	// Busco a opção de Vinculação/Desvinculação através variavel global. 
	$('#cddopcao','#frmVinculacaoParametro').val( cddoppar );
	return false;	
});

</script>

<form id="frmVinculacaoParametro" name="frmVinculacaoParametro" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select name="cddopcao" id="cddopcao" class="campo" style="width: 400px;">
				<option value="V"><? echo utf8ToHtml('V - Vincular par&acirc;metro') ?></option> 
				<option value="D"><? echo utf8ToHtml('D - Desvincular par&acirc;metro') ?></option>
			</select>
			</td>
		</tr>
		<tr>		
			<td> 	
				<input type="hidden" id="cdtarifa" name="cdtarifa" value="<? echo $cdtarifa == 0 ? '' : $cdtarifa ?>" />	
				<label for="dstarifa"><? echo utf8ToHtml('Tarifa:') ?></label>
				<input type="text" name="dstarifa" id="dstarifa"  value="<? echo utf8ToHtml($dstarifa); ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdpartar"><? echo utf8ToHtml('Par&acirc;metro:') ?></label>
				<input type="text" id="cdpartar" name="cdpartar" value="<? echo $cdpartar == 0 ? '' : $cdpartar ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(7);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
				<input type="text" name="nmpartar" id="nmpartar"  value="<? echo $nmpartar; ?>" />
			</td>
		</tr>
	</table>
</form>

<div id="tabVinculacaoParametro" name="tabVinculacaoParametro"  style="height:160px;">	
	
</div>	

<br style="clear:both" />

<div id="divBotoesVinculacaoParametro" style="margin-top:5px; margin-bottom :10px; text-align:center;">
	<a href="#" class="botao" id="btVoltar"       onClick="<? echo 'fechaRotina($(\'#divRotina\'));'?> return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir"  onClick="<? echo 'btVincular();'?> return false;">Prosseguir</a>
	<a href="#" class="botao" id="btVincular"  onClick="<? echo 'btVincular();'?> return false;">Vincular</a>
	<a href="#" class="botao" id="btDesvincular"     onClick="realizaOperacaoVinculo(D);return false;">Desvincular</a>
</div>
	
	
<script>
	highlightObjFocus( $('#frmVinculacaoParametro') );
	$('#cdpartar','#frmVinculacaoParametro').focus();
	// formataTabVinculacaoParametro();
</script>	
	