<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 25/09/2017
 * OBJETIVO     : Cabecalho para a tela CADMDE
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao">
					<option value="C"> C - Consultar </option> 
					<option value="A"> A - Alterar </option>
					<option value="I"> I - Incluir </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>								
			</td>
		</tr>
	</table>
</form>