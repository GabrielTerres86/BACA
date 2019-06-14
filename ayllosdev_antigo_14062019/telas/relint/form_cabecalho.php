<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 24/07/2013
 * OBJETIVO     : Cabeçalho para a tela RELINT
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none" >
	<input type="hidden" id="glbcoope" name="glbcoope" value="<? echo $glbvars['cdcooper'] ?>" />
	<input type="hidden" id="glbdtmvt" name="glbdtmvt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
	<table width="100%">
			<tr>		
				<td>
					<label for="cddopcao">Relat&oacute;rio:</label>
					<select id="cddopcao" name="cddopcao" style="width: 200px;">
						<option value="V">V - Visualizar / Imprimir as Senhas Bloqueadas</option> 
						<option value="R">R - Gerar relat&oacute;rio em arquivo das Senhas Bloqueadas</option> 
					</select>
					<a href="#" class="botao" id="btnOK" name="btnOK" onClick="liberaCampos(); return false;" style = "text-align:right;">OK</a>
				</td>
			</tr>
	</table>
</form>