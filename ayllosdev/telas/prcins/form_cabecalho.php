<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Cabecalho para a tela PRCINS
	 * --------------
	 * ALTERAÇÕES   : 22/03/2017 - Adicionar a opção "I - Importar planilha de prova de vida" (Douglas - Chamado 618510)
	 * --------------
	 */
	 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select class="campo" id="cddopcao" name="cddopcao">
					<option value="E">E - Exclus&atildeo de cr&eacute;dito</option> 
					<option value="I">I - Importar Planilha de Prova de Vida</option> 
					<option value="P">P - Processar Planilha de Benef&iacute;cios</option> 
					<option value="R">R - Resumo dos Lan&ccedil;amentos</option> 
					<option value="S">S - Solicita&ccedil;&atilde;o</option> 
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>