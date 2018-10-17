<?php
	/*!
    * FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 21/09/2018
	* OBJETIVO     : Cabecalho para a tela PARCBA
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<table width="100%">
		<tr>
			<td>
				<label for="cddotipo"><? echo utf8ToHtml("Op&ccedil;&atilde;o:") ?></label>
				<select class="campo" id="cddotipo" name="cddotipo">
					<option value="C"><? echo utf8ToHtml("C - Consultar Parametro") ?></option>
				    <option value="I"><? echo utf8ToHtml("P - Parametriza&ccedil;&atilde;o") ?></option> 					
					<option value="E"><? echo utf8ToHtml("E - Excluir Parametro") ?></option>					
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>

<!-- Form de Consulta de Parametro -->
<? include('form_cadastro_parametro.php'); ?>
<!-- Form de Consulta de Parametro -->
<? include('form_consulta_parametro.php'); ?>
<!-- Form de Exclusao de Parametro -->
<? include('form_excluir_parametro.php'); ?>



