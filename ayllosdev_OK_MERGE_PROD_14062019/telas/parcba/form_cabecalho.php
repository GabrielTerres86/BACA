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
					<option value="C"><? echo utf8ToHtml("C - Consultar Parametro Bancoob") ?></option>
				    <option value="I"><? echo utf8ToHtml("P - Parametriza&ccedil;&atilde;o Bancoob") ?></option>
					<option value="E"><? echo utf8ToHtml("E - Excluir Parametro Bancoob") ?></option>
					<option value="G"><? echo utf8ToHtml("G - Gerar concilia&ccedil;&atildeo Bancoob") ?></option>
					<option value="CT"><? echo utf8ToHtml("CT - Consultar Parametro Tarifa Bancoob") ?></option>
				    <option value="PT"><? echo utf8ToHtml("PT - Parametriza&ccedil;&atilde;o Tarifa Bancoob") ?></option>
					<option value="ET"><? echo utf8ToHtml("ET - Excluir Parametro Tarifa Bancoob") ?></option>
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
<!-- Form de Consulta de Parametro Tarifa -->
<? include('form_cadastro_tarifa.php'); ?>
<!-- Form de Consulta de Parametro Tarifa -->
<? include('form_consulta_tarifa.php'); ?>
<!-- Form de Geracao conciliacao -->
<? include('form_gera_conciliacao.php'); ?>