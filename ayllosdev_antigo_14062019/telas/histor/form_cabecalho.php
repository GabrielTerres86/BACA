<?php
	/*!
	* FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Jéssica (DB1)
	* DATA CRIAÇÃO : 30/09/2013
	* OBJETIVO     : Cabeçalho para a tela HISTOR
	* --------------
	* ALTERAÇÕES   : 11/03/2016 - Homologacao e ajustes da conversao da tela HISTOR (Douglas - Chamado 412552)
	*			   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	*              : 23/11/2018 - Implantacao do Projeto 421, parte 2 - Heitor (Mouts)
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" width="800px">
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao">
					<option value="C">C - Consultar</option>
					<option value="I">I - Incluir</option>
					<option value="A">A - Alterar</option>
					<option value="T">T - Alterar parametros tarifa</option>
					<option value="X">X - Replicar</option>
					<option value="B">B - Visualizar hist&oacute;ricos rotina 11 (Boletim do caixa)</option>		
					<option value="O">O - Visualizar hist&oacute;ricos rotina 56 (Inclus&atilde;o outros)</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>
