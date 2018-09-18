<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Cristian Filipe Fernandes
 * DATA CRIA��O : Novembro/2013
 * OBJETIVO     : Cabecalho para a tela CADEMP
 * --------------
 * ALTERA��ES   : 27/01/2014 - Melhorado o descritivo das op��es (Carlos)
				  05/08/2014 - Inclus�o da op��o de Pesquisa de Empresas (Vanessa)
 *                03/07/2015 - Projeto 158 - Folha de pagamento
 *                (Andre Santos - SUPERO)
 * ------------------------------------------------------------------------------------
 */

	session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Consultar empresa</option>
					<option value='A'>A - Alterar empresa</option>
					<option value='I'>I - Incluir empresa</option>
					<option value='T'>T - Termo Ades&atilde;o/Cancelamento de servi&ccedil;os</option>
					<option value='R'>R - Relatorio</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "LiberaFormulario();" style = "text-align:right;">OK</a>
			</td>

		</tr>
	</table>
</form>