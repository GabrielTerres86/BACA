<?
/*!
 * FONTE        	: form_cabecalho.php
 * CRIAÇÃO      	: Gabriel Capoia (DB1)
 * DATA CRIAÇÃO 	: 29/11/2011
 * OBJETIVO     	: Cabeçalho para a tela PESQDP
 * ULTIMA ALTERAÇÃO : 08/07/2013
 * --------------
 * ALTERAÇÕES   	: 08/07/2013 - Alterado para receber o novo padrão de layout do Ayllos Web. (Reinert)
 *                    13/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */

?>
<script>
function seleciona(elemID){
	document.getElementById(elemID).select();
	return false;
}
</script>
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
				
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">	
		<option value="C" selected > C - CONSULTA </option>		
		<option value="J" > J - JUSTIFICADO </option>
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<label for="operacao"><? echo utf8ToHtml('Operacao:') ?></label>
	<select id="operacao" name="operacao">	
		<option value="yes" selected >Credito</option>
		<option value="no" > Saque</option>
	</select>
			
	<label for="cdagenca"><? echo utf8ToHtml('PA:') ?></label>
	<input id="cdagenca" name="cdagenca" type="text"/>
	
	<label for="dtmvtola"><? echo utf8ToHtml('Data:') ?></label>
	<input id="dtmvtola" name="dtmvtola" onfocus="seleciona('dtmvtola')" type="text"/>
	
	<br style="clear:both" />
	
</form>