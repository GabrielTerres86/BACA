<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 06/02/2013
 * OBJETIVO     : Cabeçalho para a tela ADMISS
 * --------------
 * ALTERAÇÕES   : 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */		

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php'); 
    require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" id="glbdtmvt" name="glbdtmvt" value="<? echo $glbvars["dtmvtolt"] ?>" />
	<table width = "100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
					<option value="C"> C - Consultar dados parametrizados para admiss&atilde;o de cooperados </option> 
					<option value="A"> A - Alterar dados referente a admiss&atilde;o de cooperados </option> 
					<option value="L"> L - Listar a quantidade de admiss&otilde;es no m&ecirc;s </option> 
					<option value="D"> D - Consultar cooperados demitidos </option> 
					<option value="N"> N - Imprimir a quantidade de admiss&otilde;es no m&ecirc;s </option> 
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="botaoOK();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
	
</form>