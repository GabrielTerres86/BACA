<?
/*!
 * FONTE        : form_relatorio.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 19/01/2012
 * OBJETIVO     : Mostrar campos da opcao R = Relatorios
 * --------------
 * ALTERAÇÕES   : 06/03/2013 - Novo layout padrao (Gabriel).	
 * --------------
 */

?>
<div id="divRelatorio">
<form id="frmRelatorio" name="frmRelatorio" class="formulario" style="display:none;">


	<label for="nmrelato"><? echo utf8ToHtml('Relat&oacute;rio:') ?></label>	

	<select id="nmrelato" name="nmrelato">
	</select>

	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
		
	<div id="divBotoes" style="margin-bottom: 10px;">
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>	
		<a href="#" class="botao" id="btnImprime" onClick="imprimeRelatorio('<?php echo $glbvars["sidlogin"]; ?>'); return false;">Imprimir</a>	
	</div>
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmRelatorio')); 
</script>