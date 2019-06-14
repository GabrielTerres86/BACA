<?php
	/*!
    * FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Douglas Quisinski
	* DATA CRIAÇÃO : 08/09/2015
	* OBJETIVO     : Cabecalho para a tela PARCYB
	* --------------
	* ALTERAÇÕES   : 
	* --------------
	*/
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<table width="100%">
		<tr>
			<td>
				<label for="cddotipo"><? echo utf8ToHtml("Configurar") ?></label>
				<select class="campo" id="cddotipo" name="cddotipo">
					<option value="A"><? echo utf8ToHtml("A - Assessorias") ?></option> 
					<option value="M"><? echo utf8ToHtml("M - Motivos CIN") ?></option> 
					<option value="H"><? echo utf8ToHtml("H - Parametriza&ccedil;&atilde;o de Hist&oacute;ricos") ?></option> 
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>