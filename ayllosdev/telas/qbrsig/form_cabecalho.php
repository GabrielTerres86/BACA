<?php
	/*!
    * FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Heitor - Mouts
	* DATA CRIAÇÃO : 07/12/2018
	* OBJETIVO     : Cabecalho para a tela QBRSIG
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
					<option value="PR"><? echo utf8ToHtml("PR - Parametriza&ccedil;&atilde;o de regras") ?></option>
					<option value="PH"><? echo utf8ToHtml("PH - Parametriza&ccedil;&atilde;o de hist&oacute;ricos") ?></option>
				    <option value="QS"><? echo utf8ToHtml("QS - Quebra de sigilo") ?></option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>

<? include('form_parametro_regra.php'); ?>
<? include('form_parametro_historico.php'); ?>
<? include('form_quebra_sigilo.php'); ?>