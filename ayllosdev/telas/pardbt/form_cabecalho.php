<?php
/*!
 * FONTE        : form_menu.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : março/2018
 * OBJETIVO     : Menu de parâmetros para a tela PARDBT (Parametrização do Debitador Único)
 * --------------
 * ALTERAÇÕES   : 
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
				<label for="cddopcao">Opção:</label>
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