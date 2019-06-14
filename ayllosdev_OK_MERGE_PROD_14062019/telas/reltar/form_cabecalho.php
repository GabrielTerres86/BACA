<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 18/03/2013
 * OBJETIVO     : Cabeçalho para a tela RELTAR
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
					<label for="tprelato">Relat&oacute;rio:</label>
					<select id="tprelato" name="tprelato" style="width: 200px;">
						<option value="1">Receitas de tarifas</option> 
						<option value="2">Estornos de tarifas</option>
						<option value="3">Tarifas baixadas</option> 
						<option value="4">Tarifas pendentes de cobran&ccedil;a</option>
						<option value="5">Estouros C/C</option> 
					</select>
					<a href="#" class="botao" id="btnOK" name="btnOK" onClick="liberaCampos(); return false;" style = "text-align:right;">OK</a>
				</td>
			</tr>
	</table>
</form>