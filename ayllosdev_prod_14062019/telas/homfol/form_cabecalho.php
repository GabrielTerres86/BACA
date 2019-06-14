<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Renato Darosci
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Cabecalho para a tela HOMFOL
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
	<center>
	<table width="60%" >
		<tr>		
			<td align="center">
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Validar Comprovante de Folha de Pagamento</option>
					<option value='F'>F - Validar Arquivo de Folha de Pagamento</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "liberaCampos();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
	</center>
</form>