<form name="frmDadosFiliacao" id="frmDadosFiliacao" class="formulario">
	
	<fieldset>
	
		<legend> Filia&ccedil;&atilde;o </legend>
	
		<label for="nmmaettl">Nome da M&atilde;e:</label>
		<input name="nmmaettl" id="nmmaettl" type="text" value="<? echo getByTagName($filiacao,'nmmaettl') ?>" />
		<br />
		
		<label for="nmpaittl">Nome do Pai:</label>
		<input name="nmpaittl" id="nmpaittl" type="text" value="<? echo getByTagName($filiacao,'nmpaittl') ?>" />
		<br />

		<div id="divBotoes" style="margin-top:5px;">		
			<? if ( in_array($operacao,array('AC','FA','')) ) { ?>
				<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick=" controlaOperacaoFiliacao('CA'); return false;" />
			<? } else if ( $operacao == 'CA' ) { ?>
				<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="acessaOpcaoAbaDados(6,2,'@'); return false;" />		
				<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacaoFiliacao('AV'); return false;" />
			<? }  ?>
		</div>
	
	</fieldset>
</form>
<script type="text/javascript">
	$('#nmmaettl','#frmDadosFiliacao').focus();
</script>