<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : David Kruger      
 * DATA CRIAÇÃO : 22/02/2013
 * OBJETIVO     : Cabeçalho para a tela RELSEG
 * --------------
 * ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *				  
 * --------------
 */
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width = "100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
					<option value="C"> C - Consultar par&acirc;metros de comiss&atilde;o dos seguros  </option> 
					<option value="A"> A - Alterar par&acirc;metros de comiss&atilde;o dos seguros </option>
					<option value="R"> R - Relat&oacute;rios dos seguros Auto, Vida e Residencial </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>	
	</table>
</form>