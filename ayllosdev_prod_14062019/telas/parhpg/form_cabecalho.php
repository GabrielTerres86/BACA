<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Cabeçalho para a tela PARHPG
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" width="800px">
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao">
					<option value="A"><? echo utf8ToHtml('A - Alterar')?> </option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
			    <label for="cdcooper">Cooperativa:</label>
				<select class="campo" id="cdcooper" name="cdcooper">
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>