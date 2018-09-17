<?
/*!
 * FONTE        : form_processa.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 10/01/2012
 * OBJETIVO     : Mostrar campos da opcao P = Processar Arquivos de Debito
 * --------------
 * ALTERAÇÕES   : 06/03/2013 - Novo layout padrao (Gabriel).	
 * --------------
 */

?>
<div id="divProcessa">
<form id="frmProcessa" name="frmProcessa" class="formulario" style="display:none;">

	<label for="nmarquiv"><? echo utf8ToHtml('Nome do Arquivo:') ?></label>	
	<input name="nmarquiv" type="text"  id="nmarquiv" />
	
	<a href="#" onClick="mostraArquivos();return false;"><img src="<?php  echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
	
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes" style="margin-bottom: 10px;">
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>	
		<a href="#" class="botao" id="btnProcessa" onClick="processaArquivoDebito(); return false;">Prosseguir</a>	
	</div>
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmProcessa')); 
</script>