<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 27/08/2013
 * OBJETIVO     : Cabeçalho para a tela CADRET
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
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 200px;">
					<option value="A">A - Alterar Retorno</option> 
					<option value="C">C - Consultar Retorno</option>
					<option value="I">I - Incluir Retorno</option> 					
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="mostraProduto(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>