<?php
	/*!
	* FONTE        : form_cabecalho.php
	* CRIAÇÃO      : André Santos / SUPERO					última alteração:27/07/2016
	* DATA CRIAÇÃO : 19/07/2013
	* OBJETIVO     : Formulário - tela LISEPR
	* --------------
	* ALTERAÇÕES   : 25/02/2015 - Correção e validação da conversão realizada pela SUPERO (Adriano).
	*				 27/07/2016 - Removi o comando session_start. SD 479874. (Carlos R.)
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="T"> T - Visualizar </option>
		<option value="I"> I - Imprimir </option>
	</select>
	<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;" >OK</a>
	<br style="clear:both" />
</form>
