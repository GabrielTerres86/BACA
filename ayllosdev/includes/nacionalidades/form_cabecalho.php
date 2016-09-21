<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Kelvin Souza Ott
	 * DATA CRIAÇÃO : 13/05/2016
	 * OBJETIVO     : Cabecalho para a tela nacionalidades
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
	 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml("Op&ccedil;&atilde;o:"); ?></label>
				<select class="campo" id="cddopcao" name="cddopcao">
					<option value="C"><? echo utf8ToHtml("C - Consultar nacionalidades") ?></option> 
					<option value="I"><? echo utf8ToHtml("I - Incluir nacionalidades") ?></option> 
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>