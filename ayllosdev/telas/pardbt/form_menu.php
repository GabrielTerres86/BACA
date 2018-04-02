<?
/*!
 * FONTE        : form_menu.php
 * CRIA��O      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIA��O : 21/03/2018
 * OBJETIVO     : Menu de par�metros para a tela PARDBT
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

<form id="frmParam" name="frmParam" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddparam">Par�metro:</label>
				<select id="cddparam" name="cddparam" style="width: 460px;" onchange="limpaCabecalho()">
					<option value="H"> Cadastro de Hor�rios  </option> 
					<option value="P"> Cadastro de Prioridades  </option>
					<option value="E"> Execu��o Emergencial  </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onclick="carregaOpcoes(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>