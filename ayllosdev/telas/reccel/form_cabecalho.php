<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas Reinert
 * DATA CRIA��O : 19/01/2017
 * OBJETIVO     : Cabecalho para a tela OPECEL
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>
<form id="formImpres" ></form>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar </option> 
					<option value="R"> R - Realizar Recarga </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>	
			</td>
		</tr>
	</table>
</form>