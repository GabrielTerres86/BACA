<?php
	/*!
	 * FONTE        : form_motivo_cin.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 26/08/2015
	 * OBJETIVO     : Tela de Motivos CIN
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divTelaMotivoCin">
	<form id="frmCabMotivoCin" name="frmCabMotivoCin" class="formulario" style="display:none">
		<table width="100%">
			<tr>
				<td>
					<label for="cddopcao_motivo_cin"><? echo utf8ToHtml("Op&ccedil;&atilde;o") ?></label>
					<select class="campo" id="cddopcao_motivo_cin" name="cddopcao_motivo_cin">
						<option value="CM">C - Consultar</option> 
						<option value="IM">I - Incluir</option> 
						<option value="AM">A - Alterar</option> 
					</select>
					<a href="#" class="botao" id="btnOkMotivoCin" name="btnOkMotivoCin" style="text-align:right;">OK</a>
				</td>

			</tr>
		</table>
	</form>
	<!-- Form de Consulta de Motivos CIN -->
	<? include('form_consulta_motivo_cin.php'); ?>
	<!-- Form de Cadastro de Motivos CIN -->
	<? include('form_cadastro_motivo_cin.php'); ?>
</div>