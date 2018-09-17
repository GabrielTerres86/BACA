<?
/*!
 * FONTE        : form_log_processo.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 18/01/2012
 * OBJETIVO     : Mostrar campos da opcao X = Log do Processamento
 * --------------
 * ALTERAÇÕES   : 06/03/2013 - Novo layout padrao (Gabriel).	
 * --------------
 */

?>
<div id="divLogProcesso">
<form id="frmLogProcesso" name="frmLogProcesso" class="formulario" style="display:none;">


	<label for="dtinicio"><? echo utf8ToHtml('Data Inicial:') ?></label>	
	<input name="dtinicio" type="text"  id="dtinicio" />
	
	<label for="dtfim"><? echo utf8ToHtml('Data Final:') ?></label>	
	<input name="dtfim" type="text"  id="dtfim" />
	
	<a href="#" class="botao" id="btnOK" onClick="exibeLog(); return false;">OK</a>	
	
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
	<br/>
	
	<div id="divLog">
	</div>
	
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
		
	<div id="divBotoes" style="margin-bottom: 10px;">
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>	
	</div>
	
</form>
</div>


<script type='text/javascript'>
	highlightObjFocus($('#frmLogProcesso')); 
</script>