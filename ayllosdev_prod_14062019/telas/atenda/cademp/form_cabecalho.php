<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Cristian Filipe Fernandes
 * DATA CRIAÇÃO : Novembro/2013
 * OBJETIVO     : Cabecalho para a tela CADEMP
 * --------------
 * ALTERAÇÕES   : 27/01/2014 - Melhorado o descritivo das opções (Carlos)
 *				  05/08/2014 - Inclusão da opção de Pesquisa de Empresas (Vanessa)
 *                03/07/2015 - Projeto 158 - Folha de pagamento (Andre Santos - SUPERO)
 *				  28/07/2016 - Removi o comando session_start desnecessário. SD 491425 (Carlos R.)
 * ------------------------------------------------------------------------------------
 */

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