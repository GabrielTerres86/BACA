<?php
	/*!
	* FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Rogerius Militão (DB1)
	* DATA CRIAÇÃO : 30/01/2012
	* OBJETIVO     : Cabeçalho para a tela CUSTOD
	* --------------
	* ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar as cust&oacute;dias de cheques.</option>
	<option value="D" <?php echo $cddopcao == 'D' ? 'selected' : '' ?>>D - Alterar cheque de cust&oacute;dia para cheque de desconto.</option>
	<option value="F" <?php echo $cddopcao == 'F' ? 'selected' : '' ?>>F - Consultar o fechamento das cust&oacute;dias de cheques.</option>
	<option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?>>M - Imprimir as cust&oacute;dias de cheques.</option>
	<option value="O" <?php echo $cddopcao == 'O' ? 'selected' : '' ?>>O - Emitir relat&oacute;rio para confer&ecirc;ncia.</option>
	<option value="P" <?php echo $cddopcao == 'P' ? 'selected' : '' ?>>P - Pesquisar uma cust&oacute;dia de cheque espec&iacute;fica.</option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>>R - Listar os lotes de cust&oacute;dias de cheques.</option>
	<option value="S" <?php echo $cddopcao == 'S' ? 'selected' : '' ?>>S - Consultar o saldo cont&aacute;bil.</option>
	<option value="T" <?php echo $cddopcao == 'T' ? 'selected' : '' ?>>T - Pesquisar uma cust&oacute;dia informando apenas o valor.</option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>