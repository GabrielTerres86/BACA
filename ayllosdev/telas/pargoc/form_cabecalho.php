<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Afonso
 * DATA CRIAÇÃO : 04/10/2017
 * OBJETIVO     : Cabeçalho para a tela PARGOC
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" width="700px">
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao">
					<option value="A"><? echo utf8ToHtml('A - Alterar Par&acirc;metros')?> </option>
					<option value="C"><? echo utf8ToHtml('C - Consultar Par&acirc;metros')?> </option>
				</select>
			</td>
			<td>
			    <label for="cdcooper">Cooperativa:</label>
				<select class="campo" id="cdcooper" name="cdcooper" disabled>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>