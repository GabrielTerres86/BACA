<?
/*
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : Outubro/2016									ÚLTIMA ALTERAÇÃO: --/--/----
 * OBJETIVO     : Cabeçalho para a tela
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">	

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="C"> C - Distribui&ccedil;&atilde;o de valores Sysphera X Prazo</option> 
		<option value="R"> R - Configura&ccedil;&atilde;o das Remessas do Fluxo</option>
		<option value="H"> H - Hor&aacute;rio de Bloqueio do Fluxo</option>
		<option value="M"> M - Margens de seguran&ccedil;a para o Fluxo</option>
	</select>
	
	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>
	
	<br style="clear:both" />	

</form>

