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
		<option value="H"> H - Configura&ccedil;&atilde;o Históricos por Remessas</option>
	</select>
	
	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>
	
	<br style="clear:both" />	

</form>

