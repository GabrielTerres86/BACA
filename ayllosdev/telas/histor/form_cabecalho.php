<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 30/09/2013
 * OBJETIVO     : Cabeçalho para a tela HISTOR
 * --------------
 * ALTERAÇÕES   : 11/03/2016 - Homologacao e ajustes da conversao da tela HISTOR (Douglas - Chamado 412552)
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
					<option value="C"><? echo utf8ToHtml('C - Consultar')?> </option>
					<option value="I"><? echo utf8ToHtml('I - Incluir')?> </option>
					<option value="A"><? echo utf8ToHtml('A - Alterar')?> </option>
					<option value="X"><? echo utf8ToHtml('X - Replicar') ?> </option>
					<option value="B"><? echo utf8ToHtml('B - Visualizar hist&oacute;ricos rotina 11 (Boletim do caixa)') ?> </option>		
					<option value="O"><? echo utf8ToHtml('O - Visualizar hist&oacute;ricos rotina 56 (Inclus&atilde;o outros)') ?> </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>