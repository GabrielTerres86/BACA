<?php
/*!
 * FONTE        : form_menu.php
 * CRIA��O      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIA��O : mar�o/2018
 * OBJETIVO     : Menu de par�metros para a tela PARDBT (Parametriza��o do Debitador �nico)
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');

	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op��o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> Consultar  </option> 
					<option value="I"> Incluir  </option>
					<option value="A"> Alterar  </option>
					<option value="E"> Excluir  </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onclick="carregaOpcoes(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>