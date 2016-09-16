<?
/*!
 * FONTE        : form_parametro_coop.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 07/03/2012 
 * OBJETIVO     : Tela de exibição parametro por coop.
 * --------------
 * ALTERAÇÕES   :
 */		
?>

<script>
 $(document).ready(function() {

	var op = '<? echo $opcao; ?>';
	
	controlaParametroCoop();
	controlaClassConteudo();
	
	if ( ( op == 'A' ) || ( op == 'R' ) ){
		$('#cdcopaux', '#frmParametroCoop').val(glbTabCdcooper);
		$('#dsconteu', '#frmParametroCoop').val(glbTabDsconteu);
		$('#nmrescop', '#frmParametroCoop').val(glbTabNmrescop);
		return false;
	}
	
	$('#tpdedado', '#frmParametroCoop').val('<? echo $tpdedado; ?>');

 });
</script>

<form id="frmParametroCoop" name="frmParametroCoop" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>		
			<td> 	
				<label for="nmpartar"><? echo utf8ToHtml('Nome do par&acirc;metro:') ?></label>
				<input type="text" id="nmpartar" name="nmpartar" value="<? echo $nmpartar == '' ? '' : $nmpartar ?>" />	
			</td>
		</tr>
		<tr>		
			<td> 	
				<label for="tpdedado"><? echo utf8ToHtml('Tipo de dado:') ?></label>
				<select id="tpdedado" name="tpdedado" style="width: 260px;" >
					<option value="1"><? echo utf8ToHtml('1 - INTEIRO') ?> </option> 
					<option value="2"><? echo utf8ToHtml('2 - TEXTO') ?> </option>
					<option value="3"><? echo utf8ToHtml('3 - VALOR') ?> </option>
					<option value="4"><? echo utf8ToHtml('4 - DATA') ?> </option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdcopaux"><? echo utf8ToHtml('Cooperativa:') ?></label>
				<input type="text" id="cdcopaux" name="cdcopaux" value="<? echo $cdcooper == 0 ? '' : $cdcooper ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
				<input type="text" id="nmrescop" name="nmrescop" value="<? echo $nmrescop == '' ? '' : $nmrescop ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="dsconteu"><? echo utf8ToHtml('Conte&uacute;do:') ?></label>
				<input type="text" id="dsconteu" name="dsconteu" style="text-align:left" value="<? echo $dsconteu == '' ? '' : $dsconteu ?>" />	
			</td>
		</tr>
	</table>
</form>

<div id="divBotoesParaCoop" style="margin-top:5px; margin-bottom :10px; text-align:center;">
		<a href="#" class="botao" id="btVoltar"   onClick="<? echo 'fechaRotina($(\'#divRotina\'));'?> return false;">Voltar</a>
		<a href="#" class="botao" id="btReplica"  onclick="realizaOperacaoPco('IR'); return false;">Replicar</a>
		<a href="#" class="botao" id="btAlterar"  onClick="realizaOperacaoPco('<? echo $opcao; ?>')">Concluir</a>
</div>


<div id="divReplicar">
	
</div>