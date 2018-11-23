<?php
	/*!
    * FONTE        : form_cabecalho.php
	* CRIA��O      : Alcemir Junior - Mout's
	* DATA CRIA��O : 10/10/2018
	* OBJETIVO     : Cabecalho para a tela SLIP
	* --------------
	* ALTERA��ES   :
	* --------------
	*/
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<table width="100%">
		<tr>
			<td>
				<label for="cddotipo"><? echo utf8ToHtml("Op&ccedil;&atilde;o:") ?></label>
				<select class="campo" id="cddotipo" name="cddotipo">
					<option value="C"><? echo utf8ToHtml("C - Consultar Lan&ccedil;amento") ?></option>
				    <option value="P"><? echo utf8ToHtml("P - Parametriza&ccedil;&atilde;o") ?></option> 					
					<option value="I"><? echo utf8ToHtml("I - Incluir Lan&ccedil;amento") ?></option>										
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>

			<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo $glbvars["dtmvtolt"]; ?>" /> 
			<input type="hidden" id="cdoperad" name="cdoperad" value="<? echo $glbvars["cdoperad"]; ?>" /> 
		</tr>
	</table>
</form>

<!-- Form Selecao Param-->
<? include('form_selecao_param.php'); ?>
<!-- Form de Parametrizacao-->
<? include('form_parametrizacao.php'); ?>
<!-- Form consulta Parametrizacao-->
<? include('form_consulta_parametrizacao.php'); ?>
<!-- Form Gerencial-->
<? include('form_gerencial.php'); ?>
<!-- Form Risco-->
<? include('form_risco.php'); ?>
<!-- Form Historico-->
<? include('form_historicos.php'); ?>
<!-- Form Inclusao lanc.-->
<? include('form_incluir_lancamento.php'); ?>
<!-- Form Consulta lanc.-->
<? include('form_consulta_lancamento.php'); ?>














