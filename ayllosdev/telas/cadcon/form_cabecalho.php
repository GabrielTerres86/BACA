<?php
	/*!
    * FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Heitor Augusto Schmitt (RKAM)
	* DATA CRIAÇÃO : 06/10/2015
	* OBJETIVO     : Cabecalho para a tela CADCON
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
					<option value="I"><? echo utf8ToHtml("I - Incluir Consultores") ?></option>
					<option value="C"><? echo utf8ToHtml("C - Consultar Consultores") ?></option>
					<option value="A"><? echo utf8ToHtml("A - Alterar Consultores do PA") ?></option>
					<option value="T"><? echo utf8ToHtml("T - Transferir Contas entre Consultores do PA") ?></option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>
<!-- Form de Cadastro de Consultores -->
<? include('form_cadastro_consultor.php'); ?>
<!-- Form de Consulta de Consultores -->
<? include('form_consulta_consultor.php'); ?>
<!-- Form de Alteração de Consultores -->
<? include('form_alteracao_consultor.php'); ?>
<!-- Form de Transferência de Consultores -->
<? include('form_transferir_consultor.php'); ?>