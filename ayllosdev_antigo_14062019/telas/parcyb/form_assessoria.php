<?php
	/*!
    * FONTE        : form_assessoria.php
	* CRIAÇÃO      : Douglas Quisinski
	* DATA CRIAÇÃO : 25/08/2015
	* OBJETIVO     : Tela de Assessoria
	* --------------
	* ALTERAÇÕES   : 
	* --------------
	*/
?>
<div id="divTelaAssessoria">
	<form id="frmCabAssessoria" name="frmCabAssessoria" class="formulario">
		<table width="100%">
			<tr>
				<td>
					<label for="cddopcao_assessoria"><? echo utf8ToHtml("Op&ccedil;&atilde;o") ?></label>
					<select class="campo" id="cddopcao_assessoria" name="cddopcao_assessoria">
						<option value="CA">C - Consultar</option> 
						<option value="IA">I - Incluir</option> 
						<option value="AA">A - Alterar</option>
						<option value="EA">E - Excluir</option>
					</select>
					<a href="#" class="botao" id="btnOkAssessoria" name="btnOkAssessoria" style="text-align:right;">OK</a>
				</td>
			</tr>
		</table>
	</form>
	<!-- Form de Consulta de Assessorias -->
	<? include('form_consulta_assessoria.php'); ?>
	<!-- Form de Cadastro de Assessorias -->
	<? include('form_cadastro_assessoria.php'); ?>
	<!-- Form de Exclusão de Assessorias -->
	<? include('form_exclusao_assessoria.php'); ?>
</div>